class MemoryCouncilListToEmbeddedMemoesService
   OrderTable = {
      'мчч' => 'мч',
      'сщмчч' => 'сщмч',
      'мсвтт' => 'мсвт',
      'свтт' => 'свт',
      'прпп' => 'прп',
      'правв' => 'прав',
      'стсвтт' => 'стсвт',
      'мцц' => 'мц',
      'прпжж' => 'прпж',
      'правжж' => 'правж',
      'смщчрр' => 'сщмчр',
      'мсвтрр' => 'мсвтр',
      'прмчч' => 'прмч',
      'прмчрр' => 'прмчр',
      'прмцц' => 'прмц',
      'прмцрр' => 'прмцр',
      'апп' => 'ап',
      'рапп' => 'рап',
      'блжж' => 'блж',
      'блгвв' => 'блгв',
      'блгвжж' => 'блгвж',
      'бсрр' => 'бср',
   }

   attr_reader :calendaries

   def initialize calendaries: [], fake: false
      @calendaries = calendaries # list calendaries to convert
      @fake = fake
      @newd = 0
      @founded = 0
   end

   def counciled_ids
      @counciled_ids ||= Memory.unscoped.where.not(type: "Council").where.not(council: nil).select(:id).pluck(:id)
   end

   def slugs
      @slugs ||= Slug.where(sluggable_type: "Memory", sluggable_id: Council.unscoped.select(:id)).select(:text).pluck(:text)
   end

   def council_slugses
      @council_slugses ||= Memory.unscoped.where(id: counciled_ids).select(:id, :council).map {|x| [x.slug.text, x.council.split(/,\s*/)] }.to_h
   end

   def errors
      @errors ||= []
   end

   def error type, text
      errors << [type, text]

      nil
   end

   def show_errors
      errors.each do |(type, text)|
         Kernel.puts "[#{type}] #{text}"
      end
   end

   def aliases
      @aliases ||= Council.all.reduce({}) do |als, c|
         slug = c.slug.text
         councils = c.council&.split(/,\s*/) || []
         next als if councils.blank?

         aliases = councils.map {|x| /(.*)=$/ =~ x ? $1.gsub("?", "") : nil }.compact

         aliases.reduce(als) do |alss, alias_slug|
            if alss[alias_slug]
               error(:dup, "duplicated alias '#{alias_slug}' to memory '#{slug}', was in #{alss[alias_slug]}")
            else
               alss[alias_slug] = slug
            end

            alss
         end
      end
   end

   def host_slugs
      @host_slugs ||= slugs | aliases.keys
   end

   def host_map
      @host_map ||= council_slugses.reduce({}) do |hstsh, (slug, councils)|
         hosts = councils.map {|x| /(.*[^=])$/ =~ x ? $1.gsub("?", "") : nil }.compact

         hosts.reduce(hstsh) do |hsts, host_slug|
            if hsts[host_slug]
               hsts[host_slug] = hsts[host_slug] | [slug]
            else
               hsts[host_slug] = [slug]
            end

            hsts
         end
      end
   end

   def host_n_event_type_for host_slug
      memoes = Memo.by_slug([host_slug, aliases[host_slug]].compact).in_calendaries(calendaries)

      case memoes.size
      when 1
         [memoes.first.id, memoes.first.event.kind_code]
      when 0
         error(:no_memo, "no memoes found for the host memory '#{aliases[host_slug] || host_slug}'")
      else
         memo =
            Event::CORE.reduce(nil) do |res, code|
               res || memoes.where(events: { kind_code: code }).first
            end

         if memo
            [memo.id, memo.event.kind_code]
         else
            error(:many_memoes, "too many memoes found for host memory '#{aliases[host_slug] || host_slug}' with no core events one-by-one")
         end
      end
   end

   def event_id_for ch, event_type
      events = Event.where(kind_code: event_type, memory_id: Memory.by_slug(ch).first.id)

      case events.size
      when 1
         events.first.id
      when 0
         error(:no_event, "no events found for the type #{event_type}, and child memory '#{ch}'")
      else
         error(:many_event, "too many event for the type #{event_type}, and child memory '#{ch}'")
      end
   end

   def children
      @children ||= host_map.map do |host_slug, children|
         if host_slugs.include?(host_slug)
            children.map do |ch|
               host_memo_id, event_type = host_n_event_type_for(host_slug)
               event_id = event_id_for(ch, event_type) if event_type

               [event_id, host_memo_id] if event_id && host_memo_id
            end
         else
            error(:fake, "fake host memory '#{host_slug}' is for '#{children.join(",")}' child memories")
         end
      end.flatten(1).compact.uniq
   end

   def order_for host_memo_id
      texts = Memo.find(host_memo_id).orders.map {|o| o.tweets.map {|t| t.text }}.flatten.compact

      tweet = (texts.map { |t| OrderTable[t] }.compact.first || 'св')

      Order.joins(:tweets).where(tweets: {text: tweet}).first
   end

   def memo_titles memo, event_id
      titles_for(event_id).reduce([]) do |tt, x|
         title = Title.where(describable_id: memo.id,
                             describable_type: "Memo",
                             language_code: x.language_code,
                             alphabeth_code: x.alphabeth_code).first
         title_new = title || memo.titles.new(text: x.text, language_code: x.language_code, alphabeth_code: x.alphabeth_code)

         tt.any? {|x| x.id && x.id == title_new.id } ? tt : tt | [title_new]
      end
   end

   def titles_for event_id
      event = Event.find(event_id)

      event.memory.short_names.map {|x| x }.compact.flatten
   end

   def children_memoes
      @children_memoes ||=
      calendaries.reduce([]) do |memoes, c|
         calendary = Calendary.by_slug(c).first

         children.reduce(memoes) do |memoeses, (event_id, host_memo_id)|
            host_memo = Memo.find(host_memo_id)

            attrs = {
               calendary_id: host_memo.calendary_id,
               bind_kind_code: "соборный",
               bond_to_id: host_memo_id,
               event_id: event_id
            }

            memos = Memo.where(attrs)

            if memo = memos.first
               @founded = @founded + 1

               memo_titles(memo, event_id)
            else
               @newd = @newd + 1
               memo = memos.new(attrs)
               memo.orders << order_for(host_memo_id)
               memo_titles(memo, event_id)
               memo.valid?
            end

            memoeses | [memo]
         end
      end
   end

   def convert
      Memo.transaction do
         saveds = children_memoes.map do |child|
            child.save!(validate: false)

            child
         end

         Kernel.puts "All #{@newd} memoes are saved, found #{@founded} ones so... exiting with exception? #{@fake}"
         exit if @fake
      end
   ensure
      show_errors
   end
end
