class Scriptum < ActiveRecord::Base
   extend TotalSize
   include DistinctBy
   include Languageble
   include Tokens
   include WithLocaleNames
   include WithDescriptions

   has_many :scriptum_scribables, dependent: :delete_all
   has_many :audios, through: :scriptum_scribables, source: :scribable, source_type: :Audio
   has_one :resource_markup, dependent: :delete
   has_one :resource, validate: true, through: :resource_markup, inverse_of: :scripta
   has_one :memo, through: :resource
   has_one :memory, through: :memo
   belongs_to :bind_kind, primary_key: :key, foreign_key: :bind_kind_name, class_name: :Subject
   belongs_to :prosomeion, primary_key: :id, foreign_key: :prosomeion_id, class_name: :Scriptum
   belongs_to :bond_to, primary_key: :id, foreign_key: :bond_to_id, class_name: :Scriptum
   belongs_to :root, primary_key: :id, foreign_key: :root_id, class_name: :Scriptum

 # has_many :memo_scripta, inverse_of: :scriptum, dependent: :destroy move from Scriptum to hymnable_scripta
   has_many :hymnable_scripta, inverse_of: :scriptum, dependent: :destroy
   has_many :memoes, through: :memo_scripta
   has_many :event_roles, -> { where(hymnable_type: "EventRole") }, through: :hymnable_scripta, source: :hymnable
   has_many :events, through: :event_roles
   has_many :target, through: :memo_scripta, foreign_key: :event_id, source: :event

   scope :by_id, -> id { where(id: id.to_s.strip) }
   scope :by_title, -> title { where(title: title.strip) }
   scope :by_token, -> text, context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      join = "
             LEFT OUTER JOIN hymnable_scripta AS #{this}_hymnable_scripta
                          ON #{this}_hymnable_scripta.scriptum_id = #{this}.id
             LEFT OUTER JOIN memories AS #{this}_memories
                          ON #{this}_memories.id = #{this}_hymnable_scripta.hymnable_id
                         AND 'Memory' = #{this}_hymnable_scripta.hymnable_type
             LEFT OUTER JOIN event_roles AS #{this}_event_roles
                          ON #{this}_event_roles.id = #{this}_hymnable_scripta.hymnable_id
                         AND 'EventRole' = #{this}_hymnable_scripta.hymnable_type
                        JOIN short_names AS #{this}_short_names
                          ON (#{this}_short_names.memory_id = #{this}_event_roles.memory_id 
                          OR #{this}_short_names.memory_id = #{this}_memories.id)
                         AND #{this}_short_names.language_code IN ('#{language_codes.join("', '")}')
                         AND #{this}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      left_outer_joins(:descriptions).joins(join).
         where("unaccent(descriptions.text) ~* ?", "\\m#{text}.*").or(
         where("unaccent(#{this}.title) ~* ?", "\\m#{text}.*").or(
         where("unaccent(#{this}.author) ~* ?", "\\m#{text}.*").or(
         where("unaccent(#{this}.text) ~* ?", "\\m#{text}.*").or(
         where("unaccent(#{this}_short_names.text) ~* ?", "\\m#{text}.*"))))).
         group("#{this}_short_names.id").
         distinct_by("#{this}_short_names.id")
   end
   singleton_class.send(:alias_method, :by_query, :by_token)

   scope :by_root, -> do
      if where_clause.send(:predicates).any?
         model.where(root_id: Scriptum.select('root_id').group('root_id')).distinct
      else
         self
      end
   end

   # by unique universal numbering object: by id or by title
   scope :by_uno, ->(uno) do
      case uno.to_s
      when /^\s*$/
         none
      when /^\s*\d+\s*$/
         by_id(uno)
      else
         by_title(uno)
      end
   end

   # required for short list
   scope :with_key, -> _ do
      selector = ["#{table.name}.id AS _key"]

      select(selector).group('_key')
   end

   scope :with_value, -> context do
      join_name = table.table_alias || table.name
      selector = ["#{join_name}.title AS _value"]

      selector.unshift("#{join_name}.*") if self.select_values.dup.empty?

      select(selector.uniq).group('_value')
   end

   scope :with_bind_kind_name, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{as}_bind_kind_names.text AS _bind_kind_humanized"

      join = "LEFT OUTER JOIN subjects AS #{as}_bind_kinds
                           ON #{as}_bind_kinds.kind_code = 'TextBindKind'
                          AND #{as}_bind_kinds.key = #{this}.bind_kind_name
              LEFT OUTER JOIN descriptions AS #{as}_bind_kind_names
                           ON #{as}_bind_kind_names.describable_id = #{as}_bind_kinds.id
                          AND #{as}_bind_kind_names.describable_type = 'Subject'
                          AND #{as}_bind_kind_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_bind_kind_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{as}_bind_kind_names.text")
   end

   scope :with_ref_titles, -> context do
      this = table.table_alias || table.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector.concat [
         'root_scripta.title AS _root_ref_title',
         'bond_to_scripta.title AS _bond_to_ref_title',
         'prosomeion_scripta.title AS _prosomeion_ref_title' ]

      join = "LEFT OUTER JOIN scripta AS root_scripta
                           ON root_scripta.id = #{this}.root_id
                          AND #{this}.root_id IS NOT NULL
              LEFT OUTER JOIN scripta AS bond_to_scripta
                           ON bond_to_scripta.id = #{this}.bond_to_id
                          AND #{this}.bond_to_id IS NOT NULL
              LEFT OUTER JOIN scripta AS prosomeion_scripta
                           ON prosomeion_scripta.id = #{this}.prosomeion_id
                          AND #{this}.prosomeion_id IS NOT NULL"

      joins(join).select(selector).group(:id,
         'root_scripta.title',
         'bond_to_scripta.title',
         'prosomeion_scripta.title')
   end

   scope :with_resource, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{as}_resources.id AS _resource_id, #{as}_resource_titles.text AS _resource_title"

      join = "
         LEFT OUTER JOIN resource_markups AS #{as}_resource_markups
                      ON #{this}.id = #{as}_resource_markups.scriptum_id
         LEFT OUTER JOIN resources AS #{as}_resources
                      ON #{as}_resource_markups.resource_id = #{as}_resources.id
         LEFT OUTER JOIN descriptions AS #{as}_resource_titles
                      ON #{as}_resource_titles.describable_id = #{as}_resources.id
                     AND #{as}_resource_titles.describable_type = 'Resource'
                     AND #{as}_resource_titles.type = 'Title'
                     AND #{as}_resource_titles.language_code IN ('#{language_codes.join("', '")}')
                     AND #{as}_resource_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{as}_resource_titles.text", "#{as}_resources.id")
   end

   scope :with_target_events, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      lang_wheres = [
         "AND #{this}_event_titles.language_code IN ('#{language_codes.join("', '")}')",
         "AND #{this}_short_names.language_code IN ('#{language_codes.join("', '")}')",
      ] if language_codes.any?

      alph_wheres = [
         "AND #{this}_event_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
         "AND #{this}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
      ] if alphabeth_codes.any?

      selector = "COALESCE((
                        WITH __target_events AS (
                      SELECT hymnable_scripta.id AS id,
                             hymnable_scripta.kind AS kind,
                             #{this}_event_roles.id AS event_role_id,
                             #{this}_events.id AS event_id,
                             #{this}_short_names.text || ' (' ||
                             COALESCE(#{this}_event_titles.text, '') || ':' ||
                             #{this}_events.happened_at || ')' AS event_title
                        FROM hymnable_scripta
             LEFT OUTER JOIN memories AS #{this}_memories
                          ON #{this}_memories.id = hymnable_scripta.hymnable_id
                         AND 'Memory' = hymnable_scripta.hymnable_type
             LEFT OUTER JOIN event_roles AS #{this}_event_roles
                          ON #{this}_event_roles.id = hymnable_scripta.hymnable_id
                         AND 'EventRole' = hymnable_scripta.hymnable_type
                        JOIN events AS #{this}_events
                          ON #{this}_event_roles.event_id = #{this}_events.id
             LEFT OUTER JOIN subjects AS #{this}_event_kinds
                          ON #{this}_event_kinds.key = #{this}_events.kind_code
                         AND #{this}_event_kinds.kind_code = 'EventKind'
             LEFT OUTER JOIN descriptions AS #{this}_event_titles
                          ON #{this}_event_titles.id IS NOT NULL
                         AND (#{this}_event_titles.describable_id = #{this}_events.id
                         AND #{this}_event_titles.describable_type = 'Event'
                         AND #{this}_event_titles.type = 'Title'
                          OR #{this}_event_titles.describable_id = #{this}_event_kinds.id
                         AND #{this}_event_titles.describable_type = 'Subject'
                         AND #{this}_event_titles.type = 'Appellation')
                             #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
                        JOIN short_names AS #{this}_short_names
                          ON (#{this}_short_names.memory_id = #{this}_event_roles.memory_id 
                          OR #{this}_short_names.memory_id = #{this}_memories.id)

                             #{lang_wheres&.[](1)} #{alph_wheres&.[](1)}

                       WHERE hymnable_scripta.scriptum_id = #{this}.id
                    GROUP BY hymnable_scripta.id,
                             #{this}_short_names.text,
                             #{this}_events.id,
                             #{this}_event_roles.id,
                             hymnable_scripta.kind,
                             #{this}_events.happened_at,
                             #{this}_event_titles.text)
                      SELECT jsonb_agg(__target_events)
                        FROM __target_events), '[]'::jsonb) AS _target_events"

      select(selector).group(:id)
   end

   has_alphabeth on: %i(text title), novalidate: true

   validates_presence_of :type, :title, :bind_kind_name, :text
   validates_presence_of :bond_to_id, if: :bond?
   validates_absence_of :bond_to_id, unless: :bond?

   before_validation -> { self.bind_kind_name ||= 'несвязана' }, on: :create
   before_validation :generate_title, unless: :bond?

   # accepts_nested_attributes_for :target_events, reject_if: :all_blank, allow_destroy: true

   def bond?
      bind_kind_name != 'несвязана'
   end

   def generate_title
      tokina = self.text&.split(/\s+/) || []
      self.title ||=
         (3..tokina.size).to_a.reduce(nil) do |res, sz|
            next res if res

            pretitle = tokina[0...sz].select {|x| x.size > 2}.join(" ").sub(/[:;,._!\/-]$/, '')

            !Scriptum.where(title: pretitle).first&.text && pretitle
         end || self.text
   end

   def resource_id= value
      self.resource = Resource.find_by_id(value)
   end
end
