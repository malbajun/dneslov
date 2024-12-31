require 'strscan'

class Znamenar
   class Part
      attr_writer :measures

      def measures
         @measures ||= []
      end
   end

   class Measure
      attr_accessor :max_duration, :duration

      TONES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "H", "B"]
      ZNAM_TONES = ["", "", "", "", "", /[су]/, "м", "п", "в", ]
      TONE_MAP = {
         /[Г]/ => ["E", 2],
         /[Н]/ => ["E", 2],
         /[ц]/ => ["B", 2],
         /[г]/ => ["C", 3],
         /[н]/ => ["D", 3],
         /[су]/ => ["E", 3],
         /[м]/ => ["F", 3],
         /[п]/ => ["G", 3],
         /[в]/ => ["A", 3],
         /[М]/ => ["H", 3],
         /[П]/ => ["C", 4],
         /[В]/ => ["D", 4],
         "-" => proc { binding.pry },
         "+" => proc { binding.pry },
      }

      def initialize duration: 0
         @max_duration = 4
         @duration = duration
      end

      def has_print?
         false
      end

      def has_attributes?
         false
      end

      def notes
         @notes ||= []
      end

      def add_note note
         dur = duration + note["duration"]
         measures = [self]

         if dur > max_duration
            pre_dur = max_duration - duration
            post_dur = note["duration"] - pre_dur

            notes << Note.new(duration: pre_dur, tone: note["tone"]) if pre_dur > 0

            if post_dur > max_duration
               measure = self.class.new(duration: max_duration)
               measure.notes << Note.new(duration: max_duration, tone: note["tone"])
               measures << measure
               post_dur -= max_duration
            end

            measure = self.class.new(duration: dur - max_duration)
            measure.notes << Note.new(duration: max_duration - duration, tone: note["tone"])
            measures << measure
            self.duration = max_duration
         else
            notes << Note.new(duration: note["duration"], tone: note["tone"])

            self.duration = dur
         end

         measures
      end
   end

   class Note
      attr_accessor :duration

      def initialize duration: 0, tone: raise
         @duration = duration
         self.tone = tone
      end

      def tone= value
      end

      def is_present?
         duration > 0
      end

      # С,D,E...
      def step
      end

      # 2-4 usually
      def octave
      end

      # #b = -1 0 1
      def alter
      end

      # 1, 1/2=half, 1/4
      def type
      end

      def stem
         "down"
      end

      def text
      end
   end

   attr_reader :target, :source
   attr_accessor :composer, :title

   def initialize source: nil, target: nil
      # source is hip9 znamen notation
      @source = File.file?(source) ? IO.read(source) : source
      @target = target || tempfile.path
   end

   def tempfile
      @tempfile ||= Tempfile.new
   end

   def errors
      @errors ||= []
   end

   def error text
      $stderr.puts("E: #{text}")

      errors << text
   end

#   def has_critical_error? memo
#      %i(year_date).include?(memo.errors.first&.attribute)
#   end

   def template
      IO.read(File.join(File.dirname(__FILE__), "../../config/znamenar.xml.erb"))
   end

   #render proeprties
   def date
      Time.now
   end

   def add_part
      part = Part.new

      part.measures =
         nodes.reduce([]) do |res, node|
            binding.pry
            res + parse_note(node[:node]["notes"], res)
         end.reduce([Measure.new]) do |res, note|
            res | res.last.add_note(note)
         end
   end

   def parts
      @parts ||= [add_part]
   end

   #core
   def config
      @config ||= YAML.load(IO.read("config/znamenar.yml")).freeze
   end

   def separate_re key
      @separate_re = "(?<#{key}>[#{config["settings"]["chars"]}]*[#{config["settings"]["vowels"]}])"
   end

   def escape_code code
      pure = code.gsub(/^[#{config["settings"]["chars"]}]+/, "")

      if /(.*)\[([^\]]*)\](.*)/ =~ pure
         $2.split(/\s+/).map do |x|
            [$1&.strip, x, $3&.strip].map {|x| x.blank? ? nil : Regexp.quote(x) }.compact
         end#.join("|") + ")"
      else
         [Regexp.quote(pure)]
      end
   end

   def re
      @re ||= (
         Regexp.compile("^(" + config["rules"].map.with_index do |rule, index|
         #("(" + config["rules"].map.with_index do |rule, index|
            ee = ([rule["codes"]] | [*rule["aliases"]]).map.with_index do |r, subindex|
               code = r.map {|rr| escape_code(rr["code"]) }#.join("\s")

               [index, subindex, code]
            end
            #binding.pry if ee.size > 1
            #binding.pry if ee.map {|x|x.last}.join =~ / /
               ee
         end.flatten(1).sort_by {|x| x.last.reduce(0) {|r, x| r + x.join.size }}.reverse.map do |x|
            x.last.reduce {|r, x| r.product(x) }.map {|x| x.is_a?(Array) ? x.flatten : [x] }.map do |a|
               post = a.map.with_index {|part, index| "#{separate_re("t#{x[0]}_#{x[1]}_#{index}")}#{part}" }.join

               "(?<a#{x[0]}_#{x[1]}>#{post})"
            end
         end.join("|") + ")"))
   end

   #def remap
   #   @remap ||= config.rules.map {|rule| [rule.text, rule] }.to_h
   #end

   def parsed_flow
      str = source
      pos = 0
      res = []

      #binding.pry
      #while(str.match(/#{re}/)) do
      until(str.empty?) do
         if m = str.match(/#{re}/)
            res << m.named_captures.select {|x,y| y }.dup
            str = str[m.to_s.size..-1]
         else
            error("Invalid char '#{str[0]}' at pos #{pos}")
            str = str[1..-1]
         end
      end

      res
   end

   def nodes
      @nodes ||=
         parsed_flow.map do |x|
            x.reduce({}) do |res, (key, value)|
               case key
               when /a(\d+)_(\d+)/
                  res.merge({ node: config["rules"][$1.to_i] })
               when /t(\d+)_(\d+)_(\d+)/
                  res.merge({ value: value, indeces: [$1, $2, $3] })
               else
                  res
               end
            end
         end
   end

   def render_xml
      b = binding

      ERB.new(template, trim_mode: "<>-", eoutvar: "@rendered").result(b).strip
      File.open(target, "w+") {|x| x.puts(@rendered) } 

      $stderr.puts("Written to #{target}")
   end
end
