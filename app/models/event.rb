# kind_code[string]   наименование класса события
# memory_id[int] id памяти, событие которой произошло
# place_id[int]  id места, где произошло событие
# item_id[int]   id предмета, к которому применяется событие
#    t.string "happened_at"
#    t.string "person_name"
#    t.integer "type_number"
#    t.string "order"
#    t.string "council"
#
class Event < ApplicationRecord
   extend Informatible
   include DistinctBy
   include WithTitles
   include WithDescriptions

   CORE = [
      'Repose',
      'Veneration',
      'Passion',
      'Monasticry',
      'Marriage',
      'Family',
      'Preach',
      'Meeting',
      'Assurance',
      'Prophecy',
      'Baptism',
      'Restoration',
      'Conception',
      'Conceiving',
      'Canonization',
      'Glorification',
      'Uncovering',
      'Revival',
      'Translation',
   ]

   NOTICE = [
      'Repose',
      'Veneration',
      'Writing',
      'Appearance',
      'Miracle',
      'Resurrection',
      'Monasticry',
      'Passion',
      'Preach',
      'Council',
      'Marriage',
      'Family'
   ]

   USUAL = [
      'Marriage',
      'Exaltation',
      'Ascension',
      'Restoration',
      'Resurrection',
      'Entrance',
      'Conception',
      'Protection',
      'Conceiving',
      'Writing',
      'Sanctification',
      'Uncovering',
      'Circumcision',
      'Revival',
      'Renunciation',
      'Placing',
      'Translation',
      'Adoration',
      'Transfiguration',
      'Repose',
      'Nativity',
      'Council',
      'Meeting',
      'Passion',
      'Supper',
      'Assurance',
      'Miracle',
      'Appearance',
      'Curse',
      'Preach',
      'Betraial',
      'Rest',
      'Learning',
      'Genum',
      'Prophecy',
      'Baptism',
   ]

   SORT = [
      'Genum',
      'Nativity',
      'Resurrection',
   ]

   ######################
   # references relations
   belongs_to :place, optional: true
   belongs_to :item, optional: true
   belongs_to :kind, primary_key: :key, foreign_key: :kind_code, class_name: :Subject

   ########################
   # has one/many realtions
   has_many :event_roles, inverse_of: :event, class_name: :EventRole, dependent: :delete_all
   has_many :kind_titles, through: :kind, source: :names
   has_many :roundels, -> { where(roundels: { roundelable_type: "Event" }) }, foreign_key: :roundelable_id, dependent: :destroy
   has_many :attitudes, as: :imageable, class_name: :ImageAttitude
   has_many :pictures, through: :attitudes
   has_many :memories, through: :event_roles, class_name: :Memory
   has_many :short_names, through: :memories
   has_many :memoes, through: :event_roles do
      def for calendary_slugs = nil
         if calendary_slugs
            calendary_ids = Calendary.by_slugs(calendary_slugs).unscope(:select).select(:id)
            self.where(calendary_id: calendary_ids)
         else
            self
         end
      end
   end
   has_many :calendaries, -> { distinct }, through: :memoes

   #####################
   # model filter scopes
   default_scope { order(created_at: :desc) }
   scope :notice, -> { where(kind_code: NOTICE) }
   scope :usual, -> { where(kind_code: USUAL) }
   scope :calendaried, ->(calendary_slugs) { self.joins(:memoes).where(memoes: { calendary_id: Calendary.by_slugs(calendary_slugs).unscope(:select).select(:id) }) }
   scope :memoed, -> { joins(:memoes).merge(Memo.licit).distinct }
   scope :memoed_for, ->(context) do
      calendary_slugs = context[:calendary_slugs]

      joins(:memoes).calendaried(calendary_slugs).merge(Memo.licit).distinct
   end

   ########################
   # by something searchers
   scope :by_token, -> text do
      left_outer_joins(:kind, :descriptions, :titles, :short_names, :kind_titles).
         merge(Subject.by_token(text)).
         where("unaccent(events.kind_code) ~* unaccent(?)", "\\m#{text}.*").or(
         where(type_number: text.to_i).or(
         where("unaccent(descriptions.text) ~* unaccent(?)", "\\m#{text}.*").or(
         where("unaccent(short_names.text) ~* unaccent(?)", "\\m#{text}.*").or(
         where("unaccent(kind_titles_events.text) ~* unaccent(?)", "\\m#{text}.*").or(
         where("unaccent(titles_events.text) ~* unaccent(?)", "\\m#{text}.*"))))))
   end
   singleton_class.send(:alias_method, :by_query, :by_token)

   scope :by_event_code, -> code do
      if code =~ /^\d+$/
         where(id: code)
      else
         left_outer_joins(:kind_titles).where(kind_titles: { text: code })
      end
   end

   scope :by_of_two_title, -> text do
      this = table.table_alias || table.name

      join = "LEFT OUTER JOIN descriptions AS #{this}_event_titles
                           ON #{this}.id = #{this}_event_titles.describable_id
                          AND #{this}_event_titles.describable_type = 'Event'
                         JOIN subjects AS #{this}_kinds
                           ON #{this}.kind_code = #{this}_kinds.key
              LEFT OUTER JOIN descriptions AS #{this}_default_titles
                           ON #{this}_kinds.id = #{this}_default_titles.describable_id
                          AND #{this}_default_titles.describable_type = 'Subject'
                          AND #{this}_default_titles.type = 'Appellation'
                         JOIN event_roles AS #{this}_event_roles
                           ON #{this}.id = #{this}_event_roles.event_id
                         JOIN slugs AS #{this}_memory_slugs
                           ON #{this}_event_roles.memory_id = #{this}_memory_slugs.sluggable_id
                          AND #{this}_memory_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN descriptions AS #{this}_memory_titles
                           ON #{this}_event_roles.memory_id = #{this}_memory_titles.describable_id
                          AND #{this}_memory_titles.describable_type = 'Memory'
              LEFT OUTER JOIN short_names AS #{this}_short_names
                           ON #{this}_event_roles.memory_id = #{this}_short_names.memory_id"

      selector = "unaccent(#{this}_event_titles.text) ~* unaccent(?)
               OR unaccent(#{this}_default_titles.text) ~* unaccent(?)
               OR unaccent(#{this}_memory_titles.text) ~* unaccent(?)
               OR #{this}_memory_slugs.text = ?
               OR #{this}_short_names.text ~* ?",
               "\\m#{text}.*", "\\m#{text}.*", "\\m#{text}.*", text, "\\m#{text}.*"

      joins(join).where(selector).distinct
   end

   scope :by_memory_id, -> memory_id do
      joins(:memories).where(memories: { id: memory_id })
   end

   scope :by_id, ->(id) { where(id: id) }

   scope :by_title_and_short_name, -> title, short_name do
      joins(:memories).merge(Memory.by_short_name(short_name)).by_title(title)
   end

   scope :by_did_and_uno, -> did, uno do
      rela = joins(:memories).merge(Memory.by_uno(uno))
      if /^[0-9]+$/ =~ did
         rela.where(id: did)
      else
         rela.by_default_or_specific_title(did)
      end.reorder(:base_year, "memories.id", :id)
   end

   # search by event title common via subject or event-specific
   scope :by_default_or_specific_title, ->(title) do
      left_outer_joins(:kind_titles, :titles).where(titles: {text: title}).or(where(kind_titles: {text: title}))
   end

   scope :by_uno, ->(uno) do
      case uno.to_s
      when /^\s*$/
         none
      when /^\d+$/
         by_id(uno)
      else
         by_default_or_specific_title(uno)
      end
   end

   scope :by_language, ->(l) do
      this = table.table_alias || table.name
      /`(?<method>(?:by_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name || rela
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      join = "LEFT OUTER JOIN descriptions AS #{as}_titles_events
                           ON #{as}_titles_events.describable_type = 'Tag'
                          AND #{as}_titles_events.describable_id = events.id
                          AND #{as}_titles_events.type = 'Title'
                         JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.event_id
              LEFT OUTER JOIN short_names AS #{as}_short_names
                           ON #{as}_short_names.memory_id = #{this}_#{as}_event_roles.memory_id"

      joins(join).
         where("#{as}_titles_events.language_code = ?", l).or(
         where("#{as}_short_names.language_code = ?", l))
   end

   scope :by_alphabeth, ->(a) do
      this = table.table_alias || table.name
      /`(?<method>(?:by_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name || rela
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      join = "LEFT OUTER JOIN descriptions AS #{as}_titles_events
                           ON #{as}_titles_events.describable_type = 'Tag'
                          AND #{as}_titles_events.describable_id = events.id
                          AND #{as}_titles_events.type = 'Title'
                         JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.event_id
              LEFT OUTER JOIN short_names AS #{as}_short_names
                           ON #{as}_short_names.memory_id = #{this}_#{as}_event_roles.memory_id"

      joins(join).
         where("#{as}_titles_events.alphabeth_code = ?", a).or(
         where("#{as}_short_names.alphabeth_code = ?", a))
   end

   #########################
   # required for short list
   scope :with_key, -> _ do
      selector = [ 'events.id AS _key' ]

      select(selector).group('_key').reorder("_key")
   end

   scope :with_memoried_value, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      lang_wheres = [
         "AND #{this}_titles.language_code IN ('#{language_codes.join("', '")}')",
         "AND #{this}_language_names.language_code IN ('#{language_codes.join("', '")}')",
         "AND #{this}_short_names.language_code IN ('#{language_codes.join("', '")}'
)",
      ] if language_codes.any?

      alph_wheres = [
         "AND #{this}_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         "AND #{this}_alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         "AND #{this}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
      ] if alphabeth_codes.any?

      join = "LEFT OUTER JOIN subjects AS event_kinds_#{method}
                           ON event_kinds_#{method}.kind_code = 'EventKind'
                          AND event_kinds_#{method}.key = #{this}.kind_code
              LEFT OUTER JOIN descriptions AS #{this}_titles
                           ON #{this}_titles.id IS NOT NULL
                          AND (#{this}_titles.describable_id = #{this}.id
                          AND #{this}_titles.describable_type = 'Event'
                          AND #{this}_titles.type = 'Title'
                           OR #{this}_titles.describable_id = event_kinds_#{method}.id
                          AND #{this}_titles.describable_type = 'Subject'
                          AND #{this}_titles.type = 'Appellation')
                              #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
              LEFT OUTER JOIN subjects AS languages
                           ON languages.key = #{this}_titles.language_code
              LEFT OUTER JOIN descriptions AS #{this}_language_names
                           ON #{this}_language_names.describable_id = languages.id
                          AND #{this}_language_names.describable_type = 'Event'
                              #{lang_wheres&.[](1)}
              LEFT OUTER JOIN subjects AS alphabeths
                           ON alphabeths.key = #{this}_titles.alphabeth_code
              LEFT OUTER JOIN descriptions AS #{this}_alphabeth_names
                           ON #{this}_alphabeth_names.describable_id = alphabeths.id
                          AND #{this}_alphabeth_names.describable_type = 'Event'
                              #{alph_wheres&.[](1)}
                         JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.event_id
              LEFT OUTER JOIN short_names AS #{this}_short_names
                           ON #{this}_short_names.memory_id = #{this}_#{as}_event_roles.memory_id
                              #{lang_wheres&.[](2)} #{alph_wheres&.[](2)}"

      selector << "#{this}_short_names.text || ' (' || #{this}_titles.text || ':' || #{this}.happened_at || ')' AS _value"
      joins(join).select(selector).group(:id,
         "#{this}_short_names.text",
         "#{this}_titles.text",
         "#{this}.happened_at")
   end

   scope :with_value, -> context do
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      selector = self.select_values.dup

      /`(?<method_name>[^']*)'/ =~ caller.grep(/delegation/)[1]

      if language_codes.any?
         lang_wheres =
            ["AND titles.language_code IN ('#{language_codes.join("', '")}')",
             "AND language_names.language_code IN ('#{language_codes.join("', '")}')"]
      end

      if alphabeth_codes.any?
         alph_wheres =
            ["AND titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
             "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"]
      end

      join = "LEFT OUTER JOIN subjects AS event_kinds_#{method_name}
                           ON event_kinds_#{method_name}.kind_code = 'EventKind'
                          AND event_kinds_#{method_name}.key = events.kind_code
              LEFT OUTER JOIN descriptions AS titles
                           ON titles.id IS NOT NULL
                          AND (titles.describable_id = events.id
                          AND titles.describable_type = 'Event'
                          AND titles.type = 'Title'
                           OR titles.describable_id = event_kinds_#{method_name}.id
                          AND titles.describable_type = 'Subject'
                          AND titles.type = 'Appellation')
                          #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
              LEFT OUTER JOIN subjects AS languages
                           ON languages.key = titles.language_code
              LEFT OUTER JOIN descriptions AS language_names
                           ON language_names.describable_id = languages.id
                          AND language_names.describable_type = 'Event'
                          #{lang_wheres&.[](1)}
              LEFT OUTER JOIN subjects AS alphabeths
                           ON alphabeths.key = titles.alphabeth_code
              LEFT OUTER JOIN descriptions AS alphabeth_names
                           ON alphabeth_names.describable_id = alphabeths.id
                          AND alphabeth_names.describable_type = 'Event'
                          #{alph_wheres&.[](1)}"

      selector << "titles.text || ' (' || events.happened_at || ')' AS _value"
      joins(join).select(selector).group(:id, "titles.text", "events.happened_at")
   end

   scope :with_memory, -> context do
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name

      selector = self.select_values.dup << "#{this}.*" <<
         "COALESCE(jsonb_build_object(
            'slug', memory_slugs.text,
            'short_name', #{this}_short_names.text)) AS _memory"

      join = "           JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.event_id
                         JOIN slugs AS memory_slugs
                           ON memory_slugs.sluggable_type = 'Memory'
                          AND memory_slugs.sluggable_id = #{this}_#{as}_event_roles.memory_id
              LEFT OUTER JOIN short_names AS #{this}_short_names
                           ON #{this}_#{as}_event_roles.memory_id = #{this}_short_names.memory_id
                          AND #{this}_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join, :memories).merge(Memory.with_names(context)).select(selector).group(:id, 'memory_slugs.text')
   end

   scope :with_icon, -> context do
      this = table.table_alias || table.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}_roundels.url AS image_url"
      join = "LEFT OUTER JOIN LATERAL (
                      SELECT #{this}_roundels.url AS url,
                             #{this}_roundels.roundelable_id AS id,
                             #{this}_roundels.roundelable_type AS type
                        FROM roundels AS #{this}_roundels
                       WHERE #{this}_roundels.url IS NOT NULL
                         AND (#{this}.id = #{this}_roundels.roundelable_id
                         AND 'Event' = #{this}_roundels.roundelable_type)
                    ORDER BY random()
                       LIMIT 1) AS #{this}_roundels
                          ON #{this}_roundels.id = #{this}.id
                         AND #{this}_roundels.type IN ('Event')"

      joins(join).select(selector).group(:id, "#{this}_roundels.url")
   end

   scope :with_item, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE(#{as}_names.text, #{as}_type_names.text) AS _item"

      if language_codes.any?
         lang_wheres = [
            "AND #{as}_names.language_code IN ('#{language_codes.join("', '")}')",
            "AND #{as}_type_names.language_code IN ('#{language_codes.join("', '")}')",
         ]
      end

      if language_codes.any? && alphabeth_codes.any?
         alph_wheres = [
            "AND #{as}_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND #{as}_type_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         ]
      end

      join = "LEFT OUTER JOIN items AS #{this}_items
                           ON #{this}_items.id = #{this}.item_id
              LEFT OUTER JOIN descriptions AS #{as}_names
                           ON #{as}_names.describable_id = #{this}_items.id
                          AND #{as}_names.describable_type = 'Item'
                             #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
              LEFT OUTER JOIN descriptions AS #{as}_type_names
                           ON #{as}_type_names.describable_id = #{this}_items.item_type_id
                          AND #{as}_type_names.describable_type = 'ItemType'
                              #{lang_wheres&.[](1)} #{alph_wheres&.[](1)}"

      joins(join).select(selector).group("#{as}_names.text", "#{as}_type_names.text")
   end

   scope :with_place, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE(#{as}_memory_short_names.text, #{as}_descriptions.text, '') AS _place" <<
                  "#{as}_slugs.sluggable_id AS _place_slug"

      join = "           JOIN event_roles AS #{as}_event_roles
                           ON #{this}.id = #{as}_event_roles.event_id
              LEFT OUTER JOIN memories AS #{as}_memories
                           ON #{as}_memories.id = COALESCE(#{this}.place_id, #{as}_event_roles.place_id)
              LEFT OUTER JOIN short_names AS #{as}_memory_short_names
                           ON #{as}_memory_short_names.memory_id = #{as}_memories.id
                          AND #{as}_memory_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_memory_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS #{as}_descriptions
                           ON #{as}_descriptions.describable_id = #{as}_memories.id
                          AND #{as}_descriptions.describable_type = 'Memory'
                          AND #{as}_descriptions.type = 'Tale'
                          AND #{as}_descriptions.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_descriptions.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN slugs AS #{as}_slugs
                           ON #{as}_slugs.sluggable_id = #{as}_memories.id
                          AND #{as}_slugs.sluggable_type = 'Memory'"

      joins(join).select(selector).group("#{as}_memory_short_names.text", "#{as}_descriptions.text", "_place_slug")
   end

   scope :with_place_name, -> context do
      language_codes = [context[:text_languages]].flatten
      alphabeth_codes = [context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)].flatten
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      ast = as.to_s.tableize
      as_model = as.to_s.camelize

      selector = "jsonb_build_object('id', #{ast}.id, 'names', COALESCE((
              WITH RECURSIVE ____names(level,path,id,name_id,name_bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,state_code,mode,feasible) AS (
              WITH RECURSIVE tt(level,path,id,name_id,bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,state_code,mode,feasible) AS (
                      SELECT 0,
                             n.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             n.alphabeth_code,
                             n.language_code,
                             n.text,
                             mn.state_code,
                             mn.mode,
                             mn.feasible
                        FROM nomina n
                        JOIN memory_names mn
                          ON mn.nomen_id = n.id
                         AND mn.memory_id = #{ast}.id
                       UNION

                      SELECT 0,
                             n.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             n.alphabeth_code,
                             n.language_code,
                             n.text,
                             tt.state_code,
                             tt.mode,
                             tt.feasible
                        FROM nomina n
                        JOIN tt
                          ON n.root_id = tt.root_id AND tt.bond_to_id = n.name_id
                        JOIN nomina nm_t
                          ON nm_t.id = tt.name_id
                         AND nm_t.language_code <> n.language_code
             LEFT OUTER JOIN memory_names mn
                          ON n.root_id = mn.nomen_id
                         AND mn.memory_id = #{ast}.id)
                      SELECT *
                        FROM tt

                       UNION
                      SELECT level + 1,
                             path || ' > ' || n.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             n.alphabeth_code,
                             n.language_code,
                             n.text,
                             t.state_code,
                             t.mode,
                             t.feasible
                        FROM nomina n
                        JOIN ____names t
                          ON n.bond_to_id = t.name_id
                         AND n.root_id = t.root_id
                        JOIN nomina nm_t
                          ON nm_t.id = t.name_id
                         AND nm_t.language_code <> n.language_code
             LEFT OUTER JOIN memory_names mn
                          ON n.root_id = mn.nomen_id
                         AND mn.memory_id = #{ast}.id),
                             ___names AS (
                      SELECT t.*
                        FROM
                     (SELECT *,
                ROW_NUMBER() OVER(PARTITION BY id ORDER BY level DESC) as r
                        FROM ____names) AS t
                       WHERE t.r = 1),
                             __names AS (
                      SELECT DISTINCT ON(id)
                             id,
                             feasible,
                             mode,
                             name_alphabeth_code,
                             name_bind_kind_name,
                             name_language_code,
                             name_text,
                             level,
                             path,
                             state_code
                        FROM ___names
                    GROUP BY id, feasible, mode, name_alphabeth_code, name_bind_kind_name, name_language_code, name_text, level, path, state_code)
                      SELECT jsonb_agg(__names)
                        FROM __names
                       WHERE __names.name_language_code IN ('#{language_codes.join("', '")}')
                         AND __names.name_alphabeth_code IN ('#{alphabeth_codes.join("', '")}')), '[]'::jsonb), 'description', #{as}_descriptions.text, 'short_name', #{ast}_short_names.text, 'slug', #{as}_slugs.text) AS _#{as}"

      join = "           JOIN events AS #{this}_#{as}_events
                           ON #{this}.id = #{this}_#{as}_events.id
              LEFT OUTER JOIN memories AS #{ast}
                           ON #{this}_#{as}_events.place_id = #{ast}.id
                          AND #{ast}.type = 'Place'
              LEFT OUTER JOIN slugs AS #{as}_slugs
                           ON #{as}_slugs.sluggable_id = #{ast}.id
                          AND #{as}_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN descriptions AS #{as}_descriptions
                           ON #{as}_descriptions.describable_id = #{ast}.id
                          AND #{as}_descriptions.describable_type = 'Memory'
                          AND #{as}_descriptions.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_descriptions.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN short_names AS #{ast}_short_names
                           ON #{ast}.id = #{ast}_short_names.memory_id
                          AND #{ast}_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{ast}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{ast}.id", "#{as}_descriptions.text", "#{as}_slugs.text", "#{ast}_short_names.text")
   end

   scope :with_short_memoes, -> context do
      language_codes = [ context[:text_languages] ].flatten
      cslugs_rule = context[:calendary_slugs] ? "AND calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela

      selector = "COALESCE((WITH __memoes AS (
                       SELECT DISTINCT ON(memoes.id)
                              memoes.id AS id,
                              memoes.year_date AS year_date,
                              jsonb_object_agg(DISTINCT COALESCE(memo_slugs.text, 'Null'),
                                                        order_titles_memoes.text) AS orders,
                              memo_titles.text AS title
                         FROM memoes
                         JOIN calendaries
                           ON calendaries.id = memoes.calendary_id
                         JOIN slugs AS calendary_slugs
                           ON calendary_slugs.sluggable_id = calendaries.id
                          AND calendary_slugs.sluggable_type = 'Calendary'
                          #{cslugs_rule}
              LEFT OUTER JOIN descriptions AS memo_titles
                           ON memo_titles.describable_id = memoes.id
                          AND memo_titles.describable_type = 'Memo'
                          AND memo_titles.type = 'Title'
                          AND memo_titles.language_code IN ('#{language_codes.join("', '")}')
              LEFT OUTER JOIN memo_orders
                           ON memo_orders.memo_id = memoes.id
              LEFT OUTER JOIN memories AS orders
                           ON orders.id = memo_orders.order_id
                          AND orders.type = 'Order'
              LEFT OUTER JOIN slugs AS memo_slugs
                           ON memo_slugs.sluggable_id = orders.id
                          AND memo_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN memo_orders AS memo_orders_memoes_join
                           ON memo_orders_memoes_join.memo_id = memoes.id
              LEFT OUTER JOIN memories AS orders_memoes_join
                           ON orders_memoes_join.id = memo_orders_memoes_join.order_id
                          AND orders_memoes_join.type = 'Order'
              LEFT OUTER JOIN descriptions AS order_titles_memoes
                           ON order_titles_memoes.describable_id = orders_memoes_join.id
                          AND order_titles_memoes.describable_type = 'Memory'
                          AND order_titles_memoes.type IN ('Tweet')
                          AND order_titles_memoes.language_code IN ('#{language_codes.join("', '")}')
                         JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}_#{as}_event_roles.event_id = #{this}.id
                        WHERE memoes.event_role_id = #{this}_#{as}_event_roles.id
                          AND memoes.bond_to_id IS NULL
                          AND memoes.id IS NOT NULL
                     GROUP BY memoes.id, year_date, title)
                       SELECT jsonb_agg(__memoes)
                         FROM __memoes), '[]'::jsonb) AS _memoes"

      #binding.pry
      select(selector).group(:id)
   end

   scope :with_attitude_to, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      this = table.table_alias || table.name
      language_codes = [context[:text_language] || context[:text_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:text_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE(#{this}_#{as}_short_names.text || '#' || #{this}.id, '') AS _#{as}"

      join = "JOIN event_roles AS #{this}_#{as}_event_roles
                ON #{this}.id = #{this}_#{as}_event_roles.event_id
              JOIN short_names AS #{this}_#{as}_short_names
                ON #{this}_#{as}_event_roles.memory_id = #{this}_#{as}_short_names.memory_id
               AND #{this}_#{as}_short_names.language_code IN ('#{language_codes.join("', '")}')
               AND #{this}_#{as}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{this}_#{as}_short_names.text")
   end

   scope :with_slug_text, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || "slug"
      ast = as.to_s.tableize
      this = table.table_alias || table.name

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE(#{this}_#{ast}.text, '') AS _#{as}"

      join = "JOIN event_roles AS #{this}_#{as}_event_roles
                ON #{this}.id = #{this}_#{as}_event_roles.event_id
              JOIN #{ast} AS #{this}_#{ast}
                ON #{this}_#{as}_event_roles.memory_id = #{this}_#{ast}.sluggable_id
               AND 'Memory' = #{this}_#{ast}.sluggable_type"

      joins(join).select(selector).group(:id, "#{this}_#{ast}.text")
   end

   scope :with_event_id, -> _context do
      this = table.table_alias || table.name

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}.id AS _event_id"

      select(selector).group(:id, "#{this}.id")
   end

   scope :with_gallery_event, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      this = table.table_alias || table.name
      language_codes = [context[:text_language] || context[:text_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:text_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE(#{as}_titles.text, #{as}_#{this}_default_titles.text, '') AS _gallery_event"

      join = "LEFT OUTER JOIN subjects AS #{this}_kinds
                           ON #{this}.kind_code = #{this}_kinds.key
              LEFT OUTER JOIN descriptions AS #{as}_#{this}_default_titles
                           ON #{this}_kinds.id = #{as}_#{this}_default_titles.describable_id
                          AND #{as}_#{this}_default_titles.describable_type = 'Subject'
                          AND #{as}_#{this}_default_titles.type = 'Appellation'
                          AND #{as}_#{this}_default_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_#{this}_default_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')

              LEFT OUTER JOIN descriptions AS #{as}_titles
                           ON #{as}_titles.describable_id = #{this}.id
                          AND #{as}_titles.describable_type = 'Event'
                          AND #{as}_titles.type = 'Title'
                          AND #{as}_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{as}_titles.text", "#{as}_#{this}_default_titles.text")
   end

   scope :with_gallery_title, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      this = table.table_alias || table.name
      language_codes = [context[:text_language] || context[:text_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:text_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE(#{as}_short_names.text, '') AS _gallery_title"

      join = "JOIN event_roles AS #{this}_#{as}_event_roles
                ON #{this}.id = #{this}_#{as}_event_roles.event_id
              JOIN short_names AS #{as}_short_names
                ON #{this}_#{as}_event_roles.memory_id = #{as}_short_names.memory_id
               AND #{as}_short_names.language_code IN ('#{language_codes.join("', '")}')
               AND #{as}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{as}_short_names.text")
   end

   scope :with_happened_at, -> context do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      language_codes = [context[:text_language] || context[:text_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:text_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector = "#{this}_memoes.happened_at AS _happened_at"

      cslugs_rule = context[:calendary_slugs] ?
         "AND #{this}_calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""

      join = "           JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.event_id
                         JOIN memoes AS #{this}_memoes
                           ON #{this}_#{as}_event_roles.id = #{this}_memoes.event_role_id
                         JOIN calendaries AS #{this}_calendaries
                           ON #{this}_calendaries.id = #{this}_memoes.calendary_id
                         JOIN slugs AS #{this}_calendary_slugs
                           ON #{this}_calendary_slugs.sluggable_id = #{this}_calendaries.id
                          AND #{this}_calendary_slugs.sluggable_type = 'Calendary'
                              #{cslugs_rule}"

      joins(join).select(selector).group(:id, "#{this}_memoes.happened_at")
   end

   scope :with_orders, -> context do
      language_codes = [ context[:text_languages] ].flatten
      cslugs_rule = context[:calendary_slugs] ? "AND calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela

      selector = "COALESCE((WITH __orders AS (
                       SELECT DISTINCT ON(memo_slugs.text)
                              COALESCE(memo_slugs.text, order_titles_memoes.text) AS slug,
                              order_titles_memoes.text AS name
                         FROM memories AS orders
              LEFT OUTER JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.event_id
              LEFT OUTER JOIN memoes
                           ON #{this}_#{as}_event_roles.id = memoes.event_role_id
              LEFT OUTER JOIN calendaries
                           ON calendaries.id = memoes.calendary_id
              LEFT OUTER JOIN slugs AS calendary_slugs
                           ON calendary_slugs.sluggable_id = calendaries.id
                          AND calendary_slugs.sluggable_type = 'Calendary'
                              #{cslugs_rule}
              LEFT OUTER JOIN memo_orders
                           ON memo_orders.memo_id = memoes.id
              LEFT OUTER JOIN slugs AS memo_slugs
                           ON memo_slugs.sluggable_id = orders.id
                          AND memo_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN descriptions AS order_titles_memoes
                           ON order_titles_memoes.describable_id = orders.id
                          AND order_titles_memoes.describable_type = 'Memory'
                          AND order_titles_memoes.type IN ('Tweet')
                          AND order_titles_memoes.language_code IN ('#{language_codes.join("', '")}')
                        WHERE orders.id = memo_orders.order_id
                          AND orders.type = 'Order'
                          AND calendaries.licit = 't'
                     GROUP BY order_titles_memoes.text, memo_slugs.text)
                       SELECT jsonb_agg(__orders)
                         FROM __orders), '[]'::jsonb) AS _orders"

      #binding.pry
      select(selector).group(:id)
   end

   scope :with_kind, -> context do
      language_codes = [context[:text_language] || context[:text_languages] || context[:language]].flatten
      alphabeth_codes = [context[:codes] || context[:text_alphabeth] || context[:alphabeth] || Languageble.alphabeth_list_for(language_codes)].flatten
      this = table.table_alias || table.name

      selector = self.select_values.dup << "#{this}.*" <<
         "COALESCE(#{this}_default_titles.text, '') AS _kind"

      join = "           JOIN subjects AS #{this}_kinds
                           ON #{this}.kind_code = #{this}_kinds.key
              LEFT OUTER JOIN descriptions AS #{this}_default_titles
                           ON #{this}_kinds.id = #{this}_default_titles.describable_id
                          AND #{this}_default_titles.type = 'Appellation'
                          AND #{this}_default_titles.describable_type = 'Subject'
                          AND #{this}_default_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_default_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group("#{this}_default_titles.text")
   end

   scope :with_title, -> context do
      language_codes = [context[:text_language] || context[:text_languages] || context[:language]].flatten
      alphabeth_codes = [context[:codes] || context[:text_alphabeth] || context[:alphabeth] || Languageble.alphabeth_list_for(language_codes)].flatten
      this = table.table_alias || table.name

      selector = self.select_values.dup << "#{this}.*" <<
         "#{this}_event_titles.text AS _title"

      join = "LEFT OUTER JOIN descriptions AS #{this}_event_titles
                           ON #{this}.id = #{this}_event_titles.describable_id
                          AND #{this}_event_titles.type = 'Title'
                          AND #{this}_event_titles.describable_type = 'Event'
                          AND #{this}_event_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_event_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group("#{this}_event_titles.text")
   end

   # with memoes and children via memoes
   scope :with_memoes, -> context do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      language_codes = [context[:text_languages]].flatten
      alphabeth_codes = context[:text_alphabeths] || Languageble.alphabeth_list_for( language_codes ).flatten
      cslugs_rule = context[:calendary_slugs] ? "AND calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""
      ch_cslugs_rule = context[:calendary_slugs] ? "AND #{this}_calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')" : ""
      list = Event::USUAL.map.with_index {|x, i| "('#{x}', #{i})" }

      selector = "COALESCE((WITH __memoes AS (
                       SELECT DISTINCT ON(memoes.id)
                              memoes.id AS id,
                              memoes.year_date AS year_date,
                              memoes.happened_at AS happened_at,
                              jsonb_object_agg(DISTINCT COALESCE(memo_slugs.text, 'Null'),
                                                        order_titles_memoes.text) AS orders,
               COALESCE((WITH ___children AS (
                       SELECT DISTINCT ON(children_slugs.text)
                              children_slugs.text AS slug
                         FROM slugs AS children_slugs
                         JOIN event_roles AS #{this}_children_event_roles
                           ON children_slugs.sluggable_id = #{this}_children_event_roles.memory_id
                          AND children_slugs.sluggable_type = 'Memory'
                         JOIN memoes AS children
                           ON children.event_role_id = #{this}_children_event_roles.id
                          AND children.bind_kind_code = 'соборный'
                         JOIN memoes AS hosts
                           ON children.bond_to_id = hosts.id
                          AND hosts.calendary_id = children.calendary_id
                          AND memoes.calendary_id = children.calendary_id
                         JOIN event_roles AS #{this}_host_event_roles
                           ON hosts.event_role_id = #{this}_host_event_roles.id
                          AND #{this}_host_event_roles.event_id = #{this}.id
                         JOIN slugs AS #{this}_calendary_slugs
                           ON #{this}_calendary_slugs.sluggable_id = memoes.calendary_id
                          AND #{this}_calendary_slugs.sluggable_type = 'Calendary'
                              #{ch_cslugs_rule})
                       SELECT COUNT(___children.slug)
                         FROM ___children), 0) AS children_total,
               COALESCE((WITH __children AS (
                       SELECT DISTINCT ON(#{this}_usual_order_table.order_no, base_year, #{this}_children_slugs.text)
                              children.id AS id,
                              #{this}_children_slugs.text AS slug,
                              #{this}_children_events.id AS event_id,
                              #{this}_usual_order_table.order_no AS usual_event_code,
                              #{this}_child_roundels.url AS roundel_url,
                              #{this}_children_short_names.text AS short_name,
                              children_order_tweets.text AS order_tweet,
                              #{this}_children_order_short_names.text AS order_short_name,
                              #{this}_children_order_titles.text AS order_title,
                              #{this}_children_titles.text AS title,
                              #{this}_children_memories.base_year AS base_year,
                              #{this}_children_events.happened_at AS happened_at,
                              #{this}_children_notes.text AS note,
                              json_agg(distinct #{this}_calendary_slugs.text) AS calendary_slugs
                         FROM memoes AS children
                         JOIN event_roles AS #{this}_#{as}_children_event_roles
                           ON children.event_role_id = #{this}_#{as}_children_event_roles.id
                         JOIN events AS #{this}_children_events
                           ON #{this}_children_events.id = #{this}_#{as}_children_event_roles.event_id
                         JOIN memories AS #{this}_children_memories
                           ON #{this}_children_memories.id = #{this}_#{as}_children_event_roles.memory_id
                         JOIN slugs AS #{this}_children_slugs
                           ON #{this}_children_slugs.sluggable_id = #{this}_#{as}_children_event_roles.memory_id
                          AND #{this}_children_slugs.sluggable_type = 'Memory'
                         JOIN calendaries AS #{this}_calendaries
                           ON #{this}_calendaries.id = memoes.calendary_id
                         JOIN slugs AS #{this}_calendary_slugs
                           ON #{this}_calendary_slugs.sluggable_id = #{this}_calendaries.id
                          AND #{this}_calendary_slugs.sluggable_type = 'Calendary'
                              #{ch_cslugs_rule}
                         JOIN short_names AS #{this}_children_short_names
                           ON #{this}_children_memories.id = #{this}_children_short_names.memory_id
                          AND #{this}_children_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN (VALUES #{list.join(", ")}) AS #{this}_usual_order_table (event_kind_code, order_no)
                           ON #{this}_usual_order_table.event_kind_code = #{this}_children_events.kind_code
              LEFT OUTER JOIN descriptions AS #{this}_children_titles
                           ON #{this}_children_titles.describable_id = children.id
                          AND #{this}_children_titles.describable_type = 'Memo'
                          AND #{this}_children_titles.type = 'Title'
                          AND #{this}_children_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN memo_orders AS #{this}_children_memo_orders
                           ON #{this}_children_memo_orders.memo_id = children.id
              LEFT OUTER JOIN memories AS #{this}_children_orders
                           ON #{this}_children_orders.id = #{this}_children_memo_orders.order_id
                          AND #{this}_children_orders.type = 'Order'
              LEFT OUTER JOIN short_names AS #{this}_children_order_short_names
                           ON #{this}_children_orders.id = #{this}_children_order_short_names.memory_id
                          AND #{this}_children_order_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_order_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS children_order_tweets
                           ON children_order_tweets.describable_id = #{this}_children_orders.id
                          AND children_order_tweets.describable_type = 'Memory'
                          AND children_order_tweets.type = 'Tweet'
                          AND children_order_tweets.language_code IN ('#{language_codes.join("', '")}')
                          AND children_order_tweets.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS #{this}_children_order_titles
                           ON #{this}_children_order_titles.describable_id = #{this}_children_orders.id
                          AND #{this}_children_order_titles.describable_type = 'Memory'
                          AND #{this}_children_order_titles.type = 'Note'
                          AND #{this}_children_order_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_order_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN LATERAL (
                       SELECT #{this}_child_roundels.url AS url,
                              #{this}_child_roundels.roundelable_id AS id,
                              #{this}_child_roundels.roundelable_type AS type
                         FROM roundels AS #{this}_child_roundels
                        WHERE #{this}_child_roundels.url IS NOT NULL
                          AND (#{this}_#{as}_children_event_roles.memory_id = #{this}_child_roundels.roundelable_id
                          AND 'Memory' = #{this}_child_roundels.roundelable_type
                           OR #{this}_children_events.id = #{this}_child_roundels.roundelable_id
                          AND 'Event' = #{this}_child_roundels.roundelable_type)
                     ORDER BY random()
                        LIMIT 1) AS #{this}_child_roundels
                           ON #{this}_child_roundels.type IN ('Memory', 'Event')
              LEFT OUTER JOIN descriptions AS #{this}_children_notes
                           ON #{this}_children_notes.describable_id = children.id
                          AND #{this}_children_notes.describable_type = 'Memo'
                          AND #{this}_children_notes.type = 'Note'
                          AND #{this}_children_notes.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_children_notes.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                        WHERE children.bond_to_id = memoes.id
                          AND children.bind_kind_code = 'соборный'
                          AND children.calendary_id = memoes.calendary_id
                     GROUP BY #{this}_children_slugs.text,
                              #{this}_children_events.id,
                              #{this}_usual_order_table.order_no,
                              #{this}_children_memories.base_year,
                              #{this}_children_events.happened_at,
                              children.id,
                              roundel_url,
                              short_name,
                              order_tweet,
                              order_title,
                              order_short_name,
                              title,
                              note
                     ORDER BY #{this}_usual_order_table.order_no, base_year, #{this}_children_slugs.text
                        LIMIT 25)
                       SELECT jsonb_agg(__children)
                         FROM __children), '[]'::jsonb) AS children,
                              memo_titles.text AS title,
                              memo_descriptions.text AS description,
                              memo_links.url AS url,
                              calendary_links.url AS calendary_url,
                              calendary_slugs.text AS calendary_slug,
                              calendary_titles.text AS calendary_title
                         FROM memoes
                         JOIN calendaries
                           ON calendaries.id = memoes.calendary_id
                         JOIN slugs AS calendary_slugs
                           ON calendary_slugs.sluggable_id = calendaries.id
                          AND calendary_slugs.sluggable_type = 'Calendary'
                          #{cslugs_rule}
              LEFT OUTER JOIN links AS calendary_links
                           ON calendary_links.info_id = calendaries.id
                          AND calendary_links.info_type = 'Calendary'
              LEFT OUTER JOIN descriptions AS memo_titles
                           ON memo_titles.describable_id = memoes.id
                          AND memo_titles.describable_type = 'Memo'
                          AND memo_titles.type = 'Title'
                          AND memo_titles.language_code IN ('#{language_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS memo_descriptions
                           ON memo_descriptions.describable_id = memoes.id
                          AND memo_descriptions.describable_type = 'Memo'
                          AND memo_descriptions.type IN ('Description', 'Versus')
                          AND memo_descriptions.language_code IN ('#{language_codes.join("', '")}')
              LEFT OUTER JOIN links AS memo_links
                           ON memo_links.info_id = memoes.id
                          AND memo_links.info_type = 'Memo'
              LEFT OUTER JOIN descriptions AS calendary_titles
                           ON calendary_titles.describable_id = calendaries.id
                          AND calendary_titles.describable_type = 'Calendary'
                          AND calendary_titles.type = 'Appellation'
                          AND calendary_titles.language_code IN ('#{language_codes.join("', '")}')
              LEFT OUTER JOIN memo_orders
                           ON memo_orders.memo_id = memoes.id
              LEFT OUTER JOIN memories AS orders
                           ON orders.id = memo_orders.order_id
                          AND orders.type = 'Order'
              LEFT OUTER JOIN slugs AS memo_slugs
                           ON memo_slugs.sluggable_id = orders.id
                          AND memo_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN memo_orders AS memo_orders_memoes_join
                           ON memo_orders_memoes_join.memo_id = memoes.id
              LEFT OUTER JOIN memories AS orders_memoes_join
                           ON orders_memoes_join.id = memo_orders_memoes_join.order_id
                          AND orders_memoes_join.type = 'Order'
              LEFT OUTER JOIN descriptions AS order_titles_memoes
                           ON order_titles_memoes.describable_id = orders_memoes_join.id
                          AND order_titles_memoes.describable_type = 'Memory'
                          AND order_titles_memoes.type IN ('Tweet')
                          AND order_titles_memoes.language_code IN ('#{language_codes.join("', '")}')
                         JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}_#{as}_event_roles.event_id = #{this}.id
                        WHERE memoes.event_role_id = #{this}_#{as}_event_roles.id
                          AND calendaries.licit = 't'
                     GROUP BY memoes.id, year_date, title, description, calendary_slug,
                              calendary_title, calendary_url, memo_links.url)
                       SELECT jsonb_agg(__memoes)
                         FROM __memoes), '[]'::jsonb) AS _memoes"

      select(selector).group(:id)
   end

   scope :with_scripta, -> (context) do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      ast = as.to_s.tableize
      asm = as.to_s.singularize.camelize
      this = table.table_alias || table.name
      language_codes = [context[:service_language] || context[:service_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:service_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      calendaries_join =
         if context[:calendary_slugs]
             "JOIN calendaries AS #{this}_calendaries
                ON #{this}_calendaries.id = #{this}_memoes.calendary_id
              JOIN slugs AS #{this}_calendary_slugs
                ON #{this}_calendary_slugs.id = #{this}_calendaries.id
               AND #{this}_calendary_slugs.sluggable_type = 'Calendary'
               AND #{this}_calendary_slugs.text IN ('#{context[:calendary_slugs].join("','")}')"
         end

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE((WITH
                                    __texted_audios AS (
                             SELECT #{this}_#{ast}.id AS id,
                                    #{this}_audios.uid AS audio_uid,
                                    #{this}_audios.url AS audio_url,
                                    #{this}_audios.kind AS audio_kind
                               FROM #{ast} AS #{this}_#{ast}
                    LEFT OUTER JOIN scriptum_scribables AS #{this}_scriptum_scribables
                                 ON #{this}_#{ast}.id = #{this}_scriptum_scribables.scriptum_id
                                AND 'source' = #{this}_scriptum_scribables.kind
                    LEFT OUTER JOIN audios AS #{this}_audios
                                 ON #{this}_audios.id = #{this}_scriptum_scribables.scribable_id
                                AND 'Audio' = #{this}_scriptum_scribables.scribable_type),
                                    __#{ast} AS (
                             SELECT DISTINCT ON (#{this}_#{ast}.id)
                                    #{this}_#{ast}.id AS id,
                                    #{this}_#{ast}.text AS text,
                                    #{this}_#{ast}.tone AS tone,
                                    #{this}_#{ast}.type AS type,
                                    #{this}_#{ast}.language_code AS language_code,
                                    #{this}_#{ast}.alphabeth_code AS alphabeth_code,
                                    #{this}_#{ast}.prosomeion_id AS prosomeion_id,
                                    #{this}_#{ast}.title AS title,
                                    #{this}_#{ast}.bond_to_id AS ref_title,
                                    __texted_audios.audio_uid AS audio_uid,
                                    __texted_audios.audio_url AS audio_url,
                                    __texted_audios.audio_kind AS audio_kind
                               FROM #{ast} AS #{this}_#{ast}
                               JOIN event_roles AS #{this}_#{ast}_event_roles
                                 ON #{this}.id = #{this}_#{ast}_event_roles.event_id
                               JOIN memoes AS #{this}_memoes
                                 ON #{this}_#{ast}_event_roles.id = #{this}_memoes.event_role_id
                               JOIN memo_#{ast}
                                 ON memo_#{ast}.memo_id = #{this}_memoes.id
                                    #{calendaries_join}
                    LEFT OUTER JOIN __texted_audios
                                 ON __texted_audios.id = #{this}_#{ast}.id
                              WHERE #{this}_#{ast}.id = memo_#{ast}.scriptum_id
                                AND #{this}_#{ast}.language_code IN ('#{language_codes.join("', '")}')
                                AND #{this}_#{ast}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}'))
                             SELECT jsonb_agg(__#{ast})
                               FROM __#{ast}), '[]'::jsonb) AS _#{ast}"

      select(selector).group(:id)
   end

   scope :with_memory_short_name, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{as}_memory_short_names.text AS _memory_short_name"

      join = "LEFT OUTER JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.event_id
              LEFT OUTER JOIN short_names AS #{as}_memory_short_names
                           ON #{as}_memory_short_names.memory_id = #{this}_#{as}_event_roles.memory_id
                          AND #{as}_memory_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_memory_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{as}_memory_short_names.text")
   end

   singleton_class.send(:alias_method, :mid, :by_memory_id)

   validates_presence_of :kind, :kind_code
   validates_presence_of :memories, if: -> () do
      if @short_name && self.memories.blank?
         self.errors.add(:memories, "can't be assigned by short name '#{@short_name}'")
      end
   end

   # properties
   # as scope
   def all_pictures
      pictures
   end

   def bond_event_roles
      EventRole.joins(:memoes).merge(Memo.by_bond_to(self.memoes.select(:id)))
   end

   def memory_short_name= value
      if memory = Memory.by_short_name(@short_name = value).first
         self.memories |= [memory]
      end
   end

   def self.year_date_for year_date, date_in, julian
      return nil if date_in.blank?

      date =  [ Time, Date, DateTime ].any? {|c| date_in.is_a?(c) } && date_in || Time.parse(date_in)
      if /(?<day>\d+)\.(?<month>\d+)%(?<weekday>\d+)$/ =~ year_date
         base_date = Date.parse("#{date.year}-#{month}-#{day}")
         base_offset = weekday.to_i - base_date.wday
         (base_date + (base_offset < 1 && (base_offset + 7) || base_offset)).strftime("%d.%m")
      elsif /(?<offset>[+-]\d+)/ =~ year_date
         gap = (julian && 13.days || 0)
         easter = WhenEaster::EasterCalendar.find_greek_easter_date(date.year) - gap
         (easter + offset.to_i.days).strftime("%d.%m")
      else
         year_date
      end
   end
end
