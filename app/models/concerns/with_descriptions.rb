module WithDescriptions
   extend ActiveSupport::Concern

   def self.included base
      attr_writer :language, :alphabeth, :description

      base.class_eval do
         has_many :descriptions, -> { where(type: :Description) }, as: :describable, dependent: :delete_all do
            def for language_codes
               where(language_code: language_codes).first
            end
         end

         scope :by_description, -> description do
            this = table.table_alias || table.name
            as = "by_description_#{this}"

            join = "LEFT JOIN descriptions AS #{as}_descriptions
                           ON #{as}_descriptions.describable_id = #{this}.id
                          AND #{as}_descriptions.describable_type = '#{model}'
                          AND #{as}_descriptions.type IN ('Description', 'Note')"

            joins(join).where("#{as}_descriptions.text ~* ?", description)
         end

         scope :with_descriptions, ->(context) do
            join_name = table.table_alias || table.name
            language_codes = [context[:text_languages]].flatten.compact
            alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
            selector = self.select_values.dup
            selector << "#{join_name}.*" if selector.empty?

            if language_codes.any?
               lang_wheres = [
                  "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
                  "AND descriptions.language_code IN ('#{language_codes.join("', '")}')"
               ]
            end

            if alphabeth_codes.any?
               alph_wheres = [
                  "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
                  "AND descriptions.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
               ]
            end

            selector << "COALESCE((with __descriptions AS (
                            SELECT DISTINCT ON(descriptions.id)
                                   descriptions.id AS id,
                                   descriptions.type AS type,
                                   descriptions.text AS text,
                                   descriptions.language_code AS language_code,
                                   descriptions.alphabeth_code AS alphabeth_code,
                                   language_names.text AS language,
                                   alphabeth_names.text AS alphabeth
                              FROM descriptions
                   LEFT OUTER JOIN subjects AS languages
                                ON languages.key = descriptions.language_code
                   LEFT OUTER JOIN descriptions AS language_names
                                ON language_names.describable_id = languages.id
                               AND language_names.describable_type = 'Subject'
                                   #{lang_wheres&.first}
                   LEFT OUTER JOIN subjects AS alphabeths
                                ON alphabeths.key = descriptions.alphabeth_code
                   LEFT OUTER JOIN descriptions AS alphabeth_names
                                ON alphabeth_names.describable_id = alphabeths.id
                               AND alphabeth_names.describable_type = 'Subject'
                                   #{alph_wheres&.first}
                             WHERE descriptions.describable_id = #{join_name}.id
                               AND descriptions.describable_type = '#{model}'
                               AND descriptions.type IN ('Description', 'Note')
                                   #{lang_wheres&.last} #{alph_wheres&.last}
                          GROUP BY descriptions.id, language_names.text, alphabeth_names.text)
                            SELECT jsonb_agg(__descriptions)
                              FROM __descriptions), '[]'::jsonb) AS _descriptions"

            select(selector).group(:id)
         end

         scope :with_description, -> context do
            language_codes = [context[:text_languages]].flatten.compact
            alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
            this = table.table_alias || table.name

            selector = self.select_values.dup
            selector << "#{this}.*" if selector.empty?
            selector << "#{this}_descriptions.text AS _description"

            if language_codes.any?
               lang_where = "AND #{this}_descriptions.language_code IN ('#{language_codes.join("', '")}')"
            end

            if alphabeth_codes.any?
               alph_where = "AND #{this}_descriptions.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
            end

            join = "LEFT OUTER JOIN descriptions AS #{this}_descriptions
                                 ON #{this}_descriptions.describable_id = #{this}.id
                                AND #{this}_descriptions.describable_type = '#{model}'
                                AND #{this}_descriptions.type IN ('Description', 'Note')
                                #{lang_where} #{alph_where}"


            joins(join).select(selector.uniq).group('_description', "#{this}.id")
         end

         accepts_nested_attributes_for :descriptions, reject_if: :all_blank, allow_destroy: true

         validates :descriptions, associated: true

         before_validation :fill_in_description

         # serialized
         def description
            @description ||= descriptions.where(language_code: language, alphabeth_code: alphabeth).first&.text
         end

         if self.instance_methods.include?(:language)
            alias_method :desc_language, :language
            alias_method :desc_alphabeth, :alphabeth
         else
            define_method :desc_language do
            end
            define_method :desc_alphabeth do
            end
         end

         def language
           @language ||= desc_language || descriptions.first&.language_code
         end

         def alphabeth
            @alphabeth ||= desc_alphabeth || descriptions.first&.language_code
         end

         def fill_in_description
            if @description
               if desc = descriptions.where(language_code: language, alphabeth_code: alphabeth).first
                  desc.update_attribute(:text, @description)
               else
                  descriptions << Description.new(text: @description, language_code: language, alphabeth_code: alphabeth)
               end
            end
         end
      end
   end
end
