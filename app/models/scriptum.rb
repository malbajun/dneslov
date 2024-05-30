class Scriptum < ActiveRecord::Base
   extend TotalSize
   include Languageble
   include Tokens
   include WithLocaleNames

   has_many :memo_scripta, inverse_of: :scriptum, dependent: :destroy
   has_many :memoes, through: :memo_scripta
   has_many :targets, through: :memo_scripta, foreign_key: :memo_id, source: :memo

   scope :by_token, -> text do
      as = table.table_alias || table.name
      where("unaccent(#{as}.description) ~* unaccent(?)", "\\m#{text}.*").or(
      where("unaccent(#{as}.title) ~* unaccent(?)", "\\m#{text}.*").or(
      where("unaccent(#{as}.prosomeion_title) ~* unaccent(?)", "\\m#{text}.*").or(
      where("unaccent(#{as}.text) ~* unaccent(?)", "\\m#{text}.*"))))
   end
   singleton_class.send(:alias_method, :t, :by_token)

   # required for short list
   scope :with_key, -> _ do
      selector = ["#{table.name}.id AS _key"]

      select(selector).group('_key')
   end

   scope :with_value, -> context do
      join_name = table.table_alias || table.name
      selector = ["#{join_name}.text AS _value"]
      if self.select_values.dup.empty?
        selector.unshift("#{join_name}.*")
      end

      select(selector.uniq).group('_value')
   end

   scope :with_memoried_memoes, -> context do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?

      if language_codes.any?
         lang_wheres = [
            "AND #{this}_memo_titles.language_code IN ('#{language_codes.join("', '")}')",
            "AND #{this}_event_titles.language_code IN ('#{language_codes.join("', '")}')",
            "AND #{this}_calendary_titles.language_code IN ('#{language_codes.join("', '")}')"
         ]
      end

      if alphabeth_codes.any?
         alph_wheres = [
            "AND #{this}_memo_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND #{this}_event_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
            "AND #{this}_calendary_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
         ]
      end

      selector = "COALESCE((
                        WITH __memo_scripta AS (
                      SELECT memo_scripta.id AS id,
                             #{this}_memoes.id AS memo_id,
                             #{this}_memories.short_name || ' [' ||
                             COALESCE(#{this}_event_titles.text, '') || ' (' ||
                             #{this}_events.happened_at || ')]: ' ||
                             COALESCE(#{this}_memo_titles.text, '') || '[' ||
                             COALESCE(#{this}_calendary_titles.text, '') || ' (' ||
                             #{this}_memoes.year_date || ')]' AS memo_name,
                             memo_scripta.kind AS kind
                        FROM memo_scripta
             LEFT OUTER JOIN memoes AS #{this}_memoes
                          ON #{this}_memoes.id = memo_scripta.memo_id
             LEFT OUTER JOIN descriptions AS #{this}_memo_titles
                          ON #{this}_memo_titles.describable_id = #{this}_memoes.id
                         AND #{this}_memo_titles.describable_type = 'Memo'
                         AND #{this}_memo_titles.type = 'Title'
                             #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
             LEFT OUTER JOIN events AS #{this}_events
                          ON #{this}_memoes.event_id = #{this}_events.id
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
             LEFT OUTER JOIN calendaries AS #{this}_calendaries
                          ON #{this}_calendaries.id = #{this}_memoes.calendary_id
                        JOIN descriptions AS #{this}_calendary_titles
                          ON #{this}_calendary_titles.describable_id = #{this}_calendaries.id
                         AND #{this}_calendary_titles.describable_type = 'Calendary'
                         AND #{this}_calendary_titles.type = 'Appellation'
                             #{lang_wheres&.[](2)} #{alph_wheres&.[](2)}
             LEFT OUTER JOIN memories AS #{this}_memories
                          ON #{this}_memories.id = #{this}_events.memory_id
                       WHERE memo_scripta.scriptum_id = #{this}.id
                    GROUP BY memo_scripta.id, #{this}_memories.short_name, #{this}_memoes.id, memo_scripta.kind, #{this}_memo_titles.text, #{this}_events.happened_at ,#{this}_event_titles.text, #{this}_calendary_titles.text, #{this}_memoes.year_date)
                      SELECT jsonb_agg(__memo_scripta)
                        FROM __memo_scripta), '[]'::jsonb) AS _memo_scripta"

      select(selector).group(:id)
   end

   accepts_nested_attributes_for :memo_scripta, reject_if: :all_blank, allow_destroy: true

   has_alphabeth on: %i(text title)

   validates :type, :memo_scripta, presence: true
end
