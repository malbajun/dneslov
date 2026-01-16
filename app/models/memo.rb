# frozen_string_literal: true

require 'when_easter'

# class Memo содержит сведения о помине какой-либо памяти в календаре,
# таким образом связывая память и календарь. Может быть либо прямым обычным помином,
# содержащим поле годовой даты year_date, либо соборным помином, таким
# образом указывая на другой помин, содержащий годовую дату и имеющим род собора.
#
# add_date[string]            - дата добавления записи в календарь
# year_date[string]           - дата в году постоянная или перемещаемая, когда память отмечается
# event_id[int]               - ссылка на событие
# calendary_id[int]           - ссылка на календарь
# bind_kind_code[string]      - тип привязки к опорному помину(может быть не привязан)
# bond_to_id[int]             - ссылка на опорный помин, если nil, помин первичный
# id[int]                     - опознаватель
class Memo < ApplicationRecord
   extend TotalSize
   include WithDescriptions
   include WithTitles
   include WithLinks
   include WithNotes
   include DistinctBy
   include ByToken

   DAYS = %w(нд пн вт ср чт пт сб)
   DAYSR = DAYS.dup.reverse
   DAYSN = DAYS.dup.rotate
   CONDITIONALS = {
      '<' => (1..7),
      '>' => (-7..-1),
      '%' => (0..6),
      '~' => (-3..3),
   }

   belongs_to :calendary
   belongs_to :event
   belongs_to :bond_to, class_name: :Memo
   belongs_to :bind_kind, primary_key: :key, foreign_key: :bind_kind_code, class_name: :Subject

   has_one :memo_order
   has_one :order, through: :memo_order
   has_one :memory, through: :event
   has_one :slug, through: :memory
   has_one :roundel, -> { order(Arel.sql("random()")).select(:url).limit(1) }, through: :memory, source: :roundels
   has_one :calendary_slug, through: :calendary, source: :slug, class_name: :Slug
   has_one :memory_slug, through: :memory, source: :slug, class_name: :Slug

   has_many :memo_orders, dependent: :destroy
   has_many :orders, through: :memo_orders
   has_many :slugs, -> { distinct.reorder('id') }, through: :orders, source: :slug
   has_many :short_names, through: :memory
   has_many :order_titles, through: :orders, source: :tweets
   has_many :bond_memo_titles, through: :bond_to, source: :titles
   has_many :event_titles, through: :event, source: :titles
   has_many :services, as: :info, inverse_of: :info # TODO додаь задачу превода service_links/ServiceLink во Service
   has_many :titles, -> { title }, as: :describable, dependent: :delete_all
   has_many :notes, as: :describable, dependent: :delete_all, class_name: :Note
   has_many :versi, as: :describable, dependent: :delete_all, class_name: :Versus
   has_many :calendary_titles, through: :calendary, source: :titles, class_name: :Appellation
   has_one :original_title, -> { original_title }, as: :describable, class_name: :Original, dependent: :destroy

   delegate :quantity, to: :memory
   delegate :quantity, to: :bond_to, prefix: true, allow_nil: true
   # alias_method orig, new

   scope :primary, -> { where( bond_to_id: nil ) }
   scope :licit, -> { joins( :calendary ).where( calendaries: { licit: true })}
   scope :licit_with, ->(c) { self.left_outer_joins(:slug).licit.or(self.in_calendaries(c)) }
   scope :in_calendaries, -> calendaries_in do
      return self if calendaries_in.blank?

      # TODO make single embedded select or after fix rails bug use merge
      calendaries = calendaries_in.is_a?(String) && calendaries_in.split(',') || calendaries_in
      calendary_ids = Slug.where( text: calendaries, sluggable_type: 'Calendary' ).select( :sluggable_id )
      where( calendary_id: calendary_ids )
   end

   scope :by_slug, ->(slugs) do
      joins(:memory).merge(Memory.unscoped.by_slug(slugs)).reorder(:id)
   end

   scope :first_in_calendary, -> do
      sql = self.joins(:calendary_slug, :memory)
                .select('row_number() OVER (PARTITION BY slugs.text, memories.id)')
      self.unscope(:where, :order)
          .joins("INNER JOIN (#{sql.to_sql}) AS tmp ON tmp.row_number = 1 AND tmp.id = memoes.id")
   end

   scope :with_key, -> _ do
      join_name = table.table_alias || table.name
      selector = ["#{join_name}.id AS _key"]

      select(selector).group('_key').reorder("_key")
   end

   scope :with_value, -> context do
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      this = table.table_alias || table.name
      selector = self.select_values.dup

      if language_codes.any?
         lang_wheres =
            ["AND #{this}_titles.language_code IN ('#{language_codes.join("', '")}')",
             "AND #{this}_event_titles.language_code IN ('#{language_codes.join("', '")}')"]
      end

      if alphabeth_codes.any?
         alph_wheres =
            ["AND #{this}_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
             "AND #{this}_event_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"]
      end

      join = "LEFT OUTER JOIN descriptions AS #{this}_titles
                           ON #{this}_titles.describable_id = #{this}.id
                          AND #{this}_titles.describable_type = 'Memo'
                          AND #{this}_titles.type = 'Title'
                          #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}

              LEFT OUTER JOIN events AS #{this}_events
                           ON #{this}_events.id = #{this}.event_id
                         JOIN subjects AS #{this}_event_kinds
                           ON #{this}_event_kinds.key = #{this}_events.kind_code
                          AND #{this}_event_kinds.kind_code = 'EventKind'
                         JOIN descriptions AS #{this}_event_titles
                           ON #{this}_event_titles.id IS NOT NULL
                          AND (#{this}_event_titles.describable_id = #{this}_events.id
                          AND #{this}_event_titles.describable_type = 'Event'
                          AND #{this}_event_titles.type = 'Title'
                           OR #{this}_event_titles.describable_id = #{this}_event_kinds.id
                          AND #{this}_event_titles.describable_type = 'Subject'
                          AND #{this}_event_titles.type = 'Appellation')
                          #{lang_wheres&.[](1)} #{alph_wheres&.[](1)}
                         JOIN memories AS #{this}_memories
                           ON #{this}_memories.id = #{this}_events.memory_id
                          AND #{this}_memories.type = 'Council'"

      selector << "COALESCE(#{this}.year_date, '') || ' [' ||
         COALESCE(#{this}_titles.text, '') || '(' ||
         COALESCE(#{this}_event_titles.text, '') || ':' ||
         #{this}_events.happened_at ||')]' AS _value"

      joins(join).select(selector).group(
         :id,
         "#{this}_titles.text",
         "#{this}_events.happened_at",
         "#{this}_event_titles.text",
         "#{this}_memories.type")
   end

   scope :with_slug_text, -> do
      selector = self.select_values.dup
      if selector.empty?
         selector << 'memoes.*'
      end
      selector << 'slugs.text AS _slug'

      left_outer_joins(:slug).select(selector.uniq).group('_slug').order('_slug')
   end

   scope :by_date, ->(dates_in, julian = false) do
      return self if dates_in.blank?

      result = Memo.dates_to_days(dates_in, julian)

      where(year_date: result)
   end

   scope :by_token, -> text do
      left_outer_joins(:descriptions, :titles, :short_names, :calendary_titles).
         where( "unaccent(descriptions.text) ~* unaccent(?)", "\\m#{text}.*" ).or(
         where( "unaccent(titles_memoes.text) ~* unaccent(?)", "\\m#{text}.*" ).or(
         where( "unaccent(calendary_titles_memoes.text) ~* unaccent(?)", "\\m#{text}.*" ).or(
         where( "short_names.text ~* ?", "\\m#{text}.*" ).or(
         where( "memoes.add_date ~* ?", "\\m#{text}.*" ).or(
         where( "memoes.year_date ~* ?", "\\m#{text}.*" ))))))
   end

   scope :by_event_id, -> (event_id) do
      where(event_id: event_id)
   end

   scope :by_calendary_id, -> (calendary_id) do
      where(calendary_id: calendary_id)
   end

   scope :notice, -> { joins(:event).merge(Event.notice) }

   singleton_class.send(:alias_method, :t, :by_token)
   singleton_class.send(:alias_method, :q, :by_tokens)
   singleton_class.send(:alias_method, :d, :by_date)
   singleton_class.send(:alias_method, :c, :in_calendaries)

   scope :with_value_memoried, -> context do 
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      as = table.table_alias || table.name
      selector = self.select_values.dup

      if language_codes.any?
         lang_wheres =
            ["AND #{as}_titles.language_code IN ('#{language_codes.join("', '")}')",
             "AND #{as}_event_titles.language_code IN ('#{language_codes.join("', '")}')",
             "AND #{as}_calendary_titles.language_code IN ('#{language_codes.join("', '")}')",
             "AND #{as}_short_names.language_code IN ('#{language_codes.join("', '")}')"]
      end

      if alphabeth_codes.any?
         alph_wheres =
            ["AND #{as}_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
             "AND #{as}_event_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
             "AND #{as}_calendary_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
             "AND #{as}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"]
      end

      joi = "LEFT OUTER JOIN descriptions AS #{as}_titles
                          ON #{as}_titles.describable_id = #{as}.id
                         AND #{as}_titles.describable_type = 'Memo'
                         AND #{as}_titles.type = 'Title'
                         #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
             LEFT OUTER JOIN events AS #{as}_events
                          ON #{as}.event_id = #{as}_events.id
                        JOIN subjects AS #{as}_event_kinds
                          ON #{as}_event_kinds.key = #{as}_events.kind_code
                         AND #{as}_event_kinds.kind_code = 'EventKind'
                        JOIN descriptions AS #{as}_event_titles
                          ON #{as}_event_titles.id IS NOT NULL
                         AND (#{as}_event_titles.describable_id = #{as}_events.id
                         AND #{as}_event_titles.describable_type = 'Event'
                         AND #{as}_event_titles.type = 'Title'
                          OR #{as}_event_titles.describable_id = #{as}_event_kinds.id
                         AND #{as}_event_titles.describable_type = 'Subject'
                         AND #{as}_event_titles.type = 'Appellation')
                         #{lang_wheres&.[](1)} #{alph_wheres&.[](1)}
             LEFT OUTER JOIN calendaries AS #{as}_calendaries
                          ON #{as}_calendaries.id = #{as}.calendary_id
                        JOIN descriptions AS #{as}_calendary_titles
                          ON #{as}_calendary_titles.describable_id = #{as}_calendaries.id
                         AND #{as}_calendary_titles.describable_type = 'Calendary'
                         AND #{as}_calendary_titles.type = 'Appellation'
                         #{lang_wheres&.[](2)} #{alph_wheres&.[](2)}
             LEFT OUTER JOIN short_names AS #{as}_short_names
                          ON #{as}_short_names.memory_id = #{as}_events.memory_id
                         #{lang_wheres&.[](3)} #{alph_wheres&.[](3)}"

      selector << "#{as}_short_names.text || ' [' ||
         COALESCE(#{as}_event_titles.text, '') || ' (' ||
         #{as}_events.happened_at || ')]: ' ||
         COALESCE(#{as}_titles.text, '') || '[' ||
         COALESCE(#{as}_calendary_titles.text, '') || ' (' ||
         memoes.year_date || ')]' AS _value"

      joins(joi).select(selector).group(:id, "#{as}_short_names.text", "#{as}_events.happened_at", "#{as}_event_titles.text", "#{as}_titles.text", "#{as}_calendary_titles.text", "memoes.year_date")
   end

   scope :with_usual_event_code, -> _context do
      selector = 'usual_order_table.order_no AS _usual_event_code'
      list = Event::USUAL.map.with_index {|x, i| "('#{x}', #{i})" }
      join = "LEFT OUTER JOIN (VALUES #{list.join(", ")})
              AS usual_order_table (event_kind_code, order_no)
              ON usual_order_table.event_kind_code = events.kind_code"

      joins(:event, join).select(selector).group('_usual_event_code').order('_usual_event_code')
   end

   scope :with_sort_event_code, -> _context do
      selector = 'sort_order_table.order_no AS _sort_event_code'
      list = Event::SORT.map.with_index {|x, i| "('#{x}', #{i})" }
      join = "LEFT OUTER JOIN (VALUES #{list.join(", ")})
              AS sort_order_table (event_kind_code, order_no)
              ON sort_order_table.event_kind_code = events.kind_code"

      joins(:event, join).select(selector).group('_sort_event_code').order('_sort_event_code')
   end

   scope :with_base_year, -> do
      selector = self.select_values.dup
      if selector.empty?
         selector << 'memoes.*'
      end
      selector << 'memories.base_year AS _base_year'

      joins(:memory).select(selector).group('_base_year').order('_base_year')
   end

   scope :with_date, -> do
      this = table.table_alias || table.name
      selector = "COALESCE(#{this}.happened_at, events.happened_at) AS _happened_at"

      joins(:event).select(selector).group('_happened_at')
   end

   scope :with_roundel_url, -> do
      selector = 'roundels.url AS _roundel_url'

      left_outer_joins(:roundel).select(selector).group('_roundel_url')
#      as = table.table_alias || table.name
#      selector = self.select_values.dup
#      selector << "#{as}.*" if selector.empty?
#      selector << "COALESCE(
#                      SELECT #{as}_roundels.url AS roundel_url
#                        FROM roundels AS #{as}_roundels
#                       WHERE #{as}_roundels.roundelable_id = #{as}.id
#                         AND #{as}_roundels.roundelable_type = 'Memory'
#                    ORDER BY random()
#                       LIMIT 1) AS _roundel_url"
#
#      select(selector).group(:id)
   end

   scope :with_bond_to_title, -> context do
      join_name = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<scope_name>[^']*)'/ =~ caller.grep(/delegation/)[1]

      selector = "descriptions_#{scope_name}.text AS _bond_to_title"
      join =
         "LEFT OUTER JOIN memoes
                       AS memoes_#{scope_name}
                       ON memoes_#{scope_name}.id = #{join_name}.bond_to_id
          LEFT OUTER JOIN descriptions
                       AS descriptions_#{scope_name}
                       ON descriptions_#{scope_name}.describable_type = '#{model}'
                      AND descriptions_#{scope_name}.describable_id = memoes_#{scope_name}.id
                      AND descriptions_#{scope_name}.type = 'Title'
                      AND descriptions_#{scope_name}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                      AND descriptions_#{scope_name}.language_code IN ('#{language_codes.join("', '")}')"

      joins(join).select(selector).group('_bond_to_title')
   end

   scope :with_bond_to_detailed, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      ast = as.to_s.tableize
      asm = as.to_s.singularize.camelize
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "CASE WHEN #{this}_#{ast}_memories.type = 'Council' THEN
         COALESCE(#{this}_#{ast}.year_date, '') || ' [' ||
         COALESCE(#{this}_#{ast}_titles.text, '') || '(' ||
         COALESCE(#{this}_#{ast}_event_titles.text, '') || ':' ||
         #{this}_#{ast}_events.happened_at ||')]' ELSE NULL END AS _#{ast.singularize}"

      join =
         "LEFT OUTER JOIN #{this} AS #{this}_#{ast}
                       ON #{this}_#{ast}.id = #{this}.bond_to_id
          LEFT OUTER JOIN descriptions AS #{this}_#{ast}_titles
                       ON #{this}_#{ast}_titles.describable_type = '#{model}'
                      AND #{this}_#{ast}_titles.describable_id = #{this}_#{ast}.id
                      AND #{this}_#{ast}_titles.type = 'Title'
                      AND #{this}_#{ast}_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                      AND #{this}_#{ast}_titles.language_code IN ('#{language_codes.join("', '")}')
          LEFT OUTER JOIN events AS #{this}_#{ast}_events
                       ON #{this}_#{ast}_events.id = #{this}_#{ast}.event_id
          LEFT OUTER JOIN subjects AS #{this}_#{ast}_event_kinds
                       ON #{this}_#{ast}_event_kinds.key = #{this}_#{ast}_events.kind_code
                      AND #{this}_#{ast}_event_kinds.kind_code = 'EventKind'
          LEFT OUTER JOIN descriptions AS #{this}_#{ast}_event_titles
                       ON #{this}_#{ast}_event_titles.id IS NOT NULL
                      AND (#{this}_#{ast}_event_titles.describable_id = #{this}_#{ast}_events.id
                      AND #{this}_#{ast}_event_titles.describable_type = 'Event'
                      AND #{this}_#{ast}_event_titles.type = 'Title'
                       OR #{this}_#{ast}_event_titles.describable_id = #{this}_#{ast}_event_kinds.id
                      AND #{this}_#{ast}_event_titles.describable_type = 'Subject'
                      AND #{this}_#{ast}_event_titles.type = 'Appellation')
                      AND #{this}_#{ast}_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                      AND #{this}_#{ast}_titles.language_code IN ('#{language_codes.join("', '")}')
          LEFT OUTER JOIN memories AS #{this}_#{ast}_memories
                       ON #{this}_#{ast}_memories.id = #{this}_#{ast}_events.memory_id"

      joins(join).select(selector).group(
         "#{this}_#{ast}.year_date",
         "#{this}_#{ast}_titles.text",
         "#{this}_#{ast}_events.happened_at",
         "#{this}_#{ast}_event_titles.text",
         "#{this}_#{ast}_memories.type")
   end

   scope :with_event_title, -> context do
      join_name = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<scope_name>[^']*)'/ =~ caller.grep(/delegation/)[1]

      selector = "event_titles_#{scope_name}.text AS _event_title"
      join =
         "    LEFT OUTER JOIN events AS events_#{scope_name}
                           ON events_#{scope_name}.id = #{join_name}.event_id
              LEFT OUTER JOIN subjects AS event_kinds_#{scope_name}
                           ON event_kinds_#{scope_name}.key = events_#{scope_name}.kind_code
                          AND event_kinds_#{scope_name}.kind_code = 'EventKind'
              LEFT OUTER JOIN descriptions AS event_titles_#{scope_name}
                           ON event_titles_#{scope_name}.id IS NOT NULL
                          AND (event_titles_#{scope_name}.describable_id = events_#{scope_name}.id
                          AND event_titles_#{scope_name}.describable_type = 'Event'
                          AND event_titles_#{scope_name}.type = 'Title'
                           OR event_titles_#{scope_name}.describable_id = event_kinds_#{scope_name}.id
                          AND event_titles_#{scope_name}.describable_type = 'Subject'
                          AND event_titles_#{scope_name}.type = 'Appellation')
                          AND event_titles_#{scope_name}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                          AND event_titles_#{scope_name}.language_code IN ('#{language_codes.join("', '")}')"

      joins(join).select(selector).group('_event_title')
   end

   scope :with_calendary_slug_text, ->(context) do
      selector = 'calendary_slugs_memoes.text AS _calendary_slug'

      left_outer_joins(:calendary_slug).select(selector).group('_calendary_slug')
   end

   scope :with_orders, -> context do
      join_name = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<scope_name>[^']*)'/ =~ caller.grep(/delegation/)[1]

      selector =
         "COALESCE(jsonb_object_agg(
          DISTINCT COALESCE(slugs_#{scope_name}.text, ''), titles_#{scope_name}.text)
            FILTER (
             WHERE titles_#{scope_name}.id IS NOT NULL), '{}')
                AS _orders"
      join =
         "LEFT OUTER JOIN memo_orders AS memo_orders_#{scope_name}
                       ON memo_orders_#{scope_name}.memo_id = #{join_name}.id
          LEFT OUTER JOIN memories AS orders_#{scope_name}
                       ON orders_#{scope_name}.id = memo_orders_#{scope_name}.order_id
                      AND orders_#{scope_name}.type = 'Order'
          LEFT OUTER JOIN slugs AS slugs_#{scope_name}
                       ON slugs_#{scope_name}.sluggable_type = 'Memory'
                      AND slugs_#{scope_name}.sluggable_id = orders_#{scope_name}.id
          LEFT OUTER JOIN descriptions AS titles_#{scope_name}
                       ON titles_#{scope_name}.describable_type = 'Memory'
                      AND titles_#{scope_name}.describable_id = orders_#{scope_name}.id
                      AND titles_#{scope_name}.type = 'Tweet'
                      AND titles_#{scope_name}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                      AND titles_#{scope_name}.language_code IN ('#{language_codes.join("', '")}')"

      joins(join).select(selector)
   end

   scope :with_slug, -> do
      selector = self.select_values.dup
      if selector.empty?
         selector << 'memoes.*'
      end
      selector << 'slugs.text AS _slug'

      left_outer_joins(:slug).select(selector.uniq).group('_slug').order('_slug')
   end

   scope :with_title, -> context do
      join_name = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<scope_name>[^']*)'/ =~ caller.grep(/delegation/)[1]

      selector = self.select_values.dup | ["#{join_name}.*", "descriptions_#{scope_name}.text AS _title"]
      join =
         "LEFT OUTER JOIN descriptions AS descriptions_#{scope_name}
                       ON descriptions_#{scope_name}.describable_id = memoes.id
                      AND descriptions_#{scope_name}.describable_type = '#{model}'
                      AND descriptions_#{scope_name}.type = 'Title'
                      AND descriptions_#{scope_name}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                      AND descriptions_#{scope_name}.language_code IN ('#{language_codes.join("', '")}')"

      joins(join).select(selector.uniq).group('_title')
   end

   scope :with_bond_to_year_date, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      join = "LEFT OUTER JOIN memoes AS bond_to_memoes
                           ON memoes.bond_to_id = bond_to_memoes.id

              LEFT OUTER JOIN descriptions AS titles
                           ON titles.id IS NOT NULL
                          AND titles.describable_id = bond_to_memoes.id
                          AND titles.describable_type = 'Memo'
                          AND titles.type = 'Title'
                          AND titles.language_code IN ('#{language_codes.join("', '")}')
                          AND titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')

              LEFT OUTER JOIN events AS bond_to_memo_events
                           ON bond_to_memo_events.id = bond_to_memoes.event_id
              LEFT OUTER JOIN subjects AS bond_to_event_kinds
                           ON bond_to_event_kinds.key = bond_to_memo_events.kind_code
                          AND bond_to_event_kinds.kind_code = 'EventKind'
              LEFT OUTER JOIN descriptions AS bond_to_event_titles
                           ON bond_to_event_titles.id IS NOT NULL
                          AND (bond_to_event_titles.describable_id = bond_to_memo_events.id
                          AND bond_to_event_titles.describable_type = 'Event'
                          AND bond_to_event_titles.type = 'Title'
                           OR bond_to_event_titles.describable_id = bond_to_event_kinds.id
                          AND bond_to_event_titles.describable_type = 'Subject'
                          AND bond_to_event_titles.type = 'Appellation')
                          AND bond_to_event_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                          AND bond_to_event_titles.language_code IN ('#{language_codes.join("', '")}')"

      selector << "                    bond_to_memoes.year_date ||
                                                           ' [' ||
                  COALESCE(bond_to_memo_events.happened_at, '') ||
                                                          ' - ' ||
                        COALESCE(bond_to_event_titles.text, '') ||
                                                          ' - ' ||
                                      COALESCE(titles.text, '') ||
                  ']' AS _bond_to_year_date"

      joins(join).select(selector).group(:id,
                                         "bond_to_memoes.year_date",
                                         "titles.text",
                                         "bond_to_memo_events.happened_at",
                                         "bond_to_event_titles.text")
   end

   scope :with_memo_orders, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      if language_codes.any?
         lang_wheres = [
            "AND memo_order_titles.language_code IN ('#{language_codes.join("', '")}')",
         ]
      end

      if alphabeth_codes.any?
         alph_wheres = [
            "AND memo_order_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         ]
      end

      selector << "COALESCE((WITH __memo_orders AS (
                      SELECT DISTINCT ON(memo_orders.updated_at, memo_orders.order_id)
                             memo_orders.id AS id,
                             memo_orders.order_id AS order_id,
                             memo_order_titles.text AS order
                        FROM memo_orders
             LEFT OUTER JOIN memories AS orders
                          ON orders.id = memo_orders.order_id
                         AND orders.type = 'Order'
                        JOIN descriptions AS memo_order_titles
                          ON memo_order_titles.describable_id = orders.id
                         AND memo_order_titles.describable_type = 'Memory'
                         AND memo_order_titles.type = 'Note'
                             #{lang_wheres&.last} #{alph_wheres&.last}
                       WHERE memoes.id = memo_orders.memo_id
                    GROUP BY memo_orders.id, memo_order_titles.text
                    ORDER BY memo_orders.updated_at, memo_orders.order_id)
                      SELECT jsonb_agg(__memo_orders)
                        FROM __memo_orders), '[]'::jsonb) AS _memo_orders"

      select(selector).group(:id)
   end

   scope :with_calendary_title, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      _as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}_calendary_titles.text AS _calendary_title"

      if language_codes.any?
         lang_where = "AND #{this}_calendary_titles.language_code IN ('#{language_codes.join("', '")}')"
      end

      if alphabeth_codes.any?
         alph_where = "AND #{this}_calendary_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
      end

      join = "LEFT OUTER JOIN calendaries AS #{this}_calendaries
                           ON #{this}_calendaries.id = memoes.calendary_id
              LEFT OUTER JOIN descriptions AS #{this}_calendary_titles
                           ON #{this}_calendary_titles.describable_id = #{this}_calendaries.id
                          AND #{this}_calendary_titles.describable_type = 'Calendary'
                          AND #{this}_calendary_titles.type = 'Appellation'
                          #{lang_where} #{alph_where}"

      joins(join).select(selector).group(:id, "#{this}_calendary_titles.text")
   end

   scope :with_memory_event, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      [
        "memo_event_memories.id AS _memory_id",
        "#{this}_short_names.text AS _memory_name",
        "event_kind_titles.text || ' (' || #{this}_memo_events.happened_at || ')' AS _event_short_title"
      ].reduce(selector) { |s, v| s << v }

      if language_codes.any?
         lang_wheres = [
            "AND event_kind_titles.language_code IN ('#{language_codes.join("', '")}')",
            "AND #{this}_short_names.language_code IN ('#{language_codes.join("', '")}')",
         ]
      end

      if alphabeth_codes.any?
         alph_wheres = [
            "AND event_kind_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND #{this}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         ]
      end

      join = "LEFT OUTER JOIN events AS #{this}_memo_events
                           ON memoes.event_id = #{this}_memo_events.id
                         JOIN memories AS memo_event_memories
                           ON #{this}_memo_events.memory_id = memo_event_memories.id
              LEFT OUTER JOIN subjects AS event_kinds
                           ON event_kinds.kind_code = 'EventKind'
                          AND event_kinds.key = #{this}_memo_events.kind_code
              LEFT OUTER JOIN descriptions AS event_kind_titles
                           ON event_kind_titles.describable_id = event_kinds.id
                          AND event_kind_titles.describable_type = 'Subject'
                          AND event_kind_titles.type = 'Appellation'
                              #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
              LEFT OUTER JOIN short_names AS #{this}_short_names
                           ON #{this}_short_names.memory_id = #{this}_memo_events.memory_id
                              #{lang_wheres&.[](1)} #{alph_wheres&.[](1)}"

      joins(join).select(selector).group(:id, 'memo_event_memories.id',
                                              "#{this}_memo_events.happened_at",
                                              "#{this}_short_names.text",
                                              'event_kind_titles.text')
   end

   accepts_nested_attributes_for :services, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :titles, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :notes, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :versi, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :memo_orders, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :original_title, reject_if: :all_blank, allow_destroy: true

   validates_presence_of :calendary, :event
   validates :year_date, format: { with: /\A((0[1-9]|[1-2][0-9]|3[0-1])\.(0[1-9]|1[0-2])([%<>~][0-6])?|[+-]\d{1,3})\z/ }, if: :year_date
   validate :bind_kind_code_present, :same_calendaries, :same_memories, if: :bond_to_id

   before_validation :fix_year_date
   before_validation :fix_add_date
   before_create -> { self.bind_kind_code ||= 'несвязаный' }

   def is_counsil?
      bind_kind_code == 'соборный'
   end

   class << self
      def dates_to_days dates_in, julian
         [dates_in].flatten.map do |date_in|
            date = date_in.is_a?(Date) && date_in || Date.parse(date_in)
            new_date = date.strftime('%2d.%m')
            gap = julian && 13.days || 0
            wday = (date + gap).wday
            easter = WhenEaster::EasterCalendar.find_greek_easter_date(date.year) - gap

            relays =
               CONDITIONALS.map do |(cond, range)|
                  range.map { |x| (date - x.days).strftime('%2d.%m') + "#{cond}#{wday}" }
               end.flatten

            if !date.leap?
               relays |= relays.grep(/28\.02[%<>~]?/).map do |yeardate|
                  match = yeardate.match(/([%<>~])/)
                  match.present? && "29.02#{match[1]}#{wday}" || "29.02"
               end
            end

            [relays, new_date, format('%+i', date.to_time.yday - easter.yday)]
         end.flatten.uniq
      end
   end

   def year_date_for year
      case year_date
      when /(?<sign>[+-])(?<indent>.*)/
         mul = sign == '-' && -1 || 1
         WhenEaster::EasterCalendar.find_greek_easter_date(year.to_i) + (mul * indent.to_i).days
      when /(?<year_m>.*)%(?<date_m>.*)/
         date = Date.parse([year_m, year].join('.'))
         gap_in = date_m.to_i - date.wday
         gap = gap_in.negative? && gap_in + 7 || gap_in

         date + gap.days
      else
         Date.parse([year_date, year].join('.'))
      end
   rescue StandardError
      Time.at(0)
   end

   def same_calendaries
      if bond_to.calendary_id != calendary_id
         errors.add(:bond_to_id, "'s calendary must be the same as self calendary")
      end
   end

   def same_memories
      if is_counsil? && bond_to.memory.id == memory.id
         errors.add(:bond_to_id, "'s memory must not be the same as self memory for the counsil bind type")
      elsif !is_counsil? && bond_to.memory.id != memory.id
         errors.add(:bond_to_id, "'s memory must be the same as self memory for non counsil bind type")
      end
   end

   def bind_kind_code_present
      if bind_kind_code.blank?
         errors.add(:bind_kind_code, 'must be present when memo is bond to')
      end
   end

   def fix_add_date
      self.add_date ||= Time.zone.now.strftime('%d.%m.%Y %H:%M:%S')
   end

   def fix_year_date
      self.year_date =
      case self.year_date
      when /пасха/
         "+0"
      when /^дн\.(\d+)\.по пасхе/ #+24
         "+#{$1}"
      when /^дн\.(\d+)\.до пасхи/ #-24
         "-#{$1}"
      when /^(#{DAYS.join("|")})\.(\d+)\.по пасхе/ #+70
         daynum = DAYSN.index($1) + 1
         days = ($2.to_i - 1) * 7 + daynum
         "+#{days}"
      when /^(#{DAYS.join("|")})\.по пасхе/    #+7
         daynum = DAYSN.index($1) + 1
         "+#{daynum}"
      when /^(#{DAYS.join("|")})\.(\d+)\.до пасхи/  #-14
         daynum = DAYSR.index($1) + 1
         days = ($2.to_i - 1) * 7 + daynum
         "-#{days}"
      when /^(#{DAYS.join("|")})\.до пасхи/    #-7
         daynum = DAYSR.index($1) + 1
         "-#{daynum}"
      when /^дн\.(\d+)\.с (\d+\.\d+)$/   #29.06%7
         daynum = DAYS.index($1)
         date = Time.parse("#{$2}.1970")
         "#{date.strftime("%1d.%m")}%#{daynum}"
      when /^дн\.(\d+)\.по (\d+\.\d+)$/   #29.06<7
         date = Time.parse("#{$2}.1970") + $1.to_i
         date.strftime("%1d.%m")
      when /^(#{DAYS.join("|")})\.близ (\d+\.\d+)$/   #29.06~7
         daynum = DAYS.index($1)
         date = Time.parse("#{$2}.1970") # - 4.days
         "#{date.strftime("%1d.%m")}~#{daynum}"
      when /^(#{DAYS.join("|")})\.по (\d+\.\d+)$/   #29.06<7
         daynum = DAYS.index($1)
         date = Time.parse("#{$2}.1970")
         "#{date.strftime("%1d.%m")}<#{daynum}"
      when /^(#{DAYS.join("|")})\.до (\d+\.\d+)$/  #21.06>7
         daynum = DAYS.index($1)
         date = Time.parse("#{$2}.1970")# - 8.days
         "#{date.strftime("%1d.%m")}>#{daynum}"
      when /^(#{DAYS.join("|")})\.(\d+)\.по (\d+\.\d+)$/   #29.06<7
         daynum = DAYS.index($1)
         date = Time.parse("#{$3}.1970") + ($2.to_i - 1) * 7
         "#{date.strftime("%1d.%m")}<#{daynum}"
      when /^(#{DAYS.join("|")})\.(\d+)\.до (\d+\.\d+)$/  #21.06>7
         daynum = DAYS.index($1)
         date = Time.parse("#{$3}.1970") - 8.days - ($2.to_i - 1) * 7
         "#{date.strftime("%1d.%m")}>#{daynum}"
      when /^$/
         nil
      else
         self.year_date
      end
   end

   def datetime
      Date.new(memory.base_year, 1, 1)
   end

   def match_before?(calendary)
      datetime <= calendary.datetime
   end
end
