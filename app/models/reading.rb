class Reading < ActiveRecord::Base
   extend TotalSize
   include Tokens
   include WithDescriptions

   enum kind: %i(custom vespers matins lithurgy dinning hours)
 
   has_many :markups, -> { order(position: :asc) }
   has_many :scripta, through: :markups

   scope :with_markups, -> context do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela]&.name
      selector = self.select_values.dup
      selector.unshift("#{this}.*") if selector.empty?

      if language_codes.any?
         lang_wheres = "AND language_names.language_code IN ('#{language_codes.join("', '")}')"
      end

      if alphabeth_codes.any?
         alph_wheres = "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
      end

      selector << "COALESCE((with __markups AS (
                      SELECT DISTINCT ON(markups.id)
                             markups.id AS id,
                             markups.begin AS begin,
                             markups.end AS end,
                             markup_scripta.text AS scriptum,
                             markup_scripta.id AS scriptum_id,
                             language_names.text AS language,
                             alphabeth_names.text AS alphabeth
                        FROM markups
             LEFT OUTER JOIN scripta AS markup_scripta
                          ON markup_scripta.id = markups.scriptum_id
             LEFT OUTER JOIN subjects AS languages
                          ON languages.key = markup_scripta.language_code
             LEFT OUTER JOIN descriptions AS language_names
                          ON language_names.describable_id = languages.id
                         AND language_names.describable_type = 'Subject'
                             #{lang_wheres}
             LEFT OUTER JOIN subjects AS alphabeths
                          ON alphabeths.key = markup_scripta.alphabeth_code
             LEFT OUTER JOIN descriptions AS alphabeth_names
                          ON alphabeth_names.describable_id = alphabeths.id
                         AND alphabeth_names.describable_type = 'Subject'
                             #{alph_wheres}
                    GROUP BY markups.id, markup_scripta.id, markup_scripta.text, language_names.text, alphabeth_names.text)
                      SELECT jsonb_agg(__markups)
                        FROM __markups), '[]'::jsonb) AS _markups"

      select(selector).group(:id)
   end

   accepts_nested_attributes_for :markups, reject_if: :all_blank, allow_destroy: true

   validates :markups, associated: true
end
