module WithLocaleNames
   extend ActiveSupport::Concern

   def self.included base
      base.class_eval do
         scope :by_language, ->(l, context = {}) do
            this = table.table_alias || table.name
            language_codes = context[:language] ? [context[:language]] : context[:text_languages]
            alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)

            join = "LEFT OUTER JOIN subjects AS #{this}_languages
                                 ON #{this}_languages.key = #{this}.language_code
                    LEFT OUTER JOIN descriptions AS #{this}_language_names
                                 ON #{this}_language_names.describable_id = #{this}_languages.id
                                AND #{this}_language_names.describable_type = 'Subject'
                                AND #{this}_language_names.language_code IN ('#{language_codes.join("', '")}')"

            wheres = ["#{this}.language_code = ? OR #{this}_language_names.text = ?", l, l]

            joins(join).where(*wheres)
         end

         scope :by_alphabeth, ->(a, context = {}) do
            this = table.table_alias || table.name
            language_codes = context[:language] ? [context[:language]] : context[:text_languages]
            alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)

            join = "LEFT OUTER JOIN subjects AS #{this}_alphabeths
                                 ON #{this}_alphabeths.key = #{this}.alphabeth_code
                    LEFT OUTER JOIN descriptions AS #{this}_alphabeth_names
                                 ON #{this}_alphabeth_names.describable_id = #{this}_alphabeths.id
                                AND #{this}_alphabeth_names.describable_type = 'Subject'
                                AND #{this}_alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

            wheres = ["#{this}.alphabeth_code = ? OR #{this}_alphabeth_names.text = ?", a, a]

            joins(join).where(*wheres)
         end

         scope :with_locale_names, -> context do
            this = table.table_alias || table.name
            language_codes = [context[:text_languages]].flatten.compact
            alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
            /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
            as = model.reflections[rela]&.name
            selector = self.select_values.dup
            selector << "#{this}.*" if selector.empty?

            selector.concat [ "language_names.text AS _language", "alphabeth_names.text AS _alphabeth" ]

            if language_codes.any?
               lang_wheres = "AND language_names.language_code IN ('#{language_codes.join("', '")}')"
            end

            if alphabeth_codes.any?
               alph_wheres = "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
            end

            join = "LEFT OUTER JOIN subjects AS languages
                                 ON languages.key = #{this}.language_code
                    LEFT OUTER JOIN descriptions AS language_names
                                 ON language_names.describable_id = languages.id
                                AND language_names.describable_type = 'Subject'
                                    #{lang_wheres}
                    LEFT OUTER JOIN subjects AS alphabeths
                                 ON alphabeths.key = #{this}.alphabeth_code
                    LEFT OUTER JOIN descriptions AS alphabeth_names
                                 ON alphabeth_names.describable_id = alphabeths.id
                                AND alphabeth_names.describable_type = 'Subject'
                                    #{alph_wheres}"

            joins(join).select(selector.uniq).group(:id, 'language_names.text', 'alphabeth_names.text')
         end

         def language= value
            self.language_code ||= Subject.where(kind_code: "Language").joins(:nomina).where(nomina: { text: value}).first.key
         end

         def alphabeth= value
            self.alphabeth_code ||= Subject.where(kind_code: "Alphabeth").joins(:nomina).where(nomina: { text: value}).first.key
         end
      end
   end
end
