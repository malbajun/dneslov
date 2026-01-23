module WithLinks
   extend ActiveSupport::Concern

   def self.included base
      base.class_eval do
         has_many :links, as: :info, dependent: :delete_all

         scope :with_links, -> context do
            join_name = table.table_alias || table.name
            language_codes = [context[:text_languages]].flatten.compact
            alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
            /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
            as = model.reflections[rela]&.name
            selector = self.select_values.dup
            selector << "#{join_name}.*" if selector.empty?

            if language_codes.any?
               lang_wheres = [
                  "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
                  "AND #{as}.language_code IN ('#{language_codes.join("', '")}')"
               ]
            end

            if alphabeth_codes.any?
               alph_wheres = [
                  "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
                  "AND #{as}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
               ]
            end

            selector << "COALESCE((with __#{as} as (
                            SELECT DISTINCT ON(#{as}.id)
                                   #{as}.id as id,
                                   #{as}.type as type,
                                   #{as}.url as url,
                                   #{as}.language_code AS language_code,
                                   #{as}.alphabeth_code AS alphabeth_code,
                                   language_names.text AS language,
                                   alphabeth_names.text AS alphabeth
                              FROM #{as}
                   LEFT OUTER JOIN subjects AS languages
                                ON languages.key = #{as}.language_code
                   LEFT OUTER JOIN descriptions AS language_names
                                ON language_names.describable_id = languages.id
                               AND language_names.describable_type = 'Subject'
                                   #{lang_wheres&.first}
                   LEFT OUTER JOIN subjects AS alphabeths
                                ON alphabeths.key = #{as}.alphabeth_code
                   LEFT OUTER JOIN descriptions AS alphabeth_names
                                ON alphabeth_names.describable_id = alphabeths.id
                               AND alphabeth_names.describable_type = 'Subject'
                                   #{alph_wheres&.first}
                             WHERE #{as}.info_id = #{join_name}.id
                               AND #{as}.info_type = '#{model}'
                                   #{lang_wheres&.last} #{alph_wheres&.last}
                          GROUP BY #{as}.id, language_names.text, alphabeth_names.text)
                            SELECT jsonb_agg(__#{as})
                              FROM __#{as}), '[]'::jsonb) AS _#{as}"

            select(selector).group(:id)
         end

         scope :with_pure_links, -> do
            join_name = table.table_alias || table.name
            selector = "COALESCE((SELECT jsonb_agg(links)
                                    FROM links
                                   WHERE links.info_id = #{join_name}.id
                                     AND links.info_type = '#{model}'), '[]'::jsonb) AS _links"

            select(selector).group(:id)
         end

         accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true

         validates :links, associated: true
      end
   end
end
