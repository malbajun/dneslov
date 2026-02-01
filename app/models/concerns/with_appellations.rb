module WithAppellations
   extend ActiveSupport::Concern

   def self.included base
      base.class_eval do
         attr_writer :appellation, :appellation_language, :appellation_alphabeth, :appellation_language_code, :appellation_alphabeth_code

         has_many :appellations, as: :describable, class_name: :Appellation, dependent: :delete_all
         has_many :default_appellations, -> { distinct }, through: :kind, source: :names, class_name: :Appellation
         has_many :all_appellations, ->(this) do
            where(describable_type: model.name, describable_id: this.id, kind: "Appellation")
              .or( Appellation.merge(this.kind.names)).order(:describable_type)
         end, primary_key: nil, class_name: :Description

         scope :by_appellation, -> appellation do
            this = table.table_alias || table.name
            as = "by_appellation_#{this}"

            join = "LEFT JOIN descriptions AS #{as}_appellations
                           ON #{as}_appellations.describable_id = #{this}.id
                          AND #{as}_appellations.describable_type = '#{model}'
                          AND #{as}_appellations.type IN ('Appellation')"

            joins(join).where("#{as}_appellations.text ~* ?", appellation)
         end

         scope :with_appellations, -> context do
            this = table.table_alias || table.name
            language_codes = context[:language] ? [context[:language]] : context[:text_languages]
            alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
            /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
            as = context[:as] || model.reflections[rela]&.name || rela
            selector = self.select_values.dup
            selector << "#{model.table_name}.*" if selector.empty?

            if self.model.attribute_names.include?("kind_code")
               kind_join =
                  "LEFT OUTER JOIN subjects AS #{as}_kinds
                                ON #{as}_kinds.kind_code = '#{model.name}Kind'
                               AND #{as}_kinds.key = #{as}.kind_code"
               kind_where =
                               "OR appellations.describable_id = #{as}_kinds.id
                               AND appellations.describable_type = 'Subject'
                               AND appellations.type IN ('Appellation')"
            end

            if language_codes.any?
               lang_wheres = [
                  "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
                  "AND appellations.language_code IN ('#{language_codes.join("', '")}')"
               ]
            end

            if alphabeth_codes.any?
               alph_wheres = [
                  "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
                  "AND appellations.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
               ]
            end

            selector << "COALESCE((WITH __appellations AS (
                            SELECT DISTINCT ON(appellations.id)
                                   appellations.id AS id,
                                   appellations.type AS type,
                                   appellations.text AS text,
                                   appellations.language_code AS language_code,
                                   appellations.alphabeth_code AS alphabeth_code,
                                   language_names.text AS language,
                                   alphabeth_names.text AS alphabeth
                              FROM descriptions AS appellations
                                   #{kind_join}
                   LEFT OUTER JOIN subjects AS languages
                                ON languages.key = appellations.language_code
                   LEFT OUTER JOIN descriptions AS language_names
                                ON language_names.describable_id = languages.id
                               AND language_names.describable_type = 'Subject'
                                   #{lang_wheres&.first}
                   LEFT OUTER JOIN subjects AS alphabeths
                                ON alphabeths.key = appellations.alphabeth_code
                   LEFT OUTER JOIN descriptions AS alphabeth_names
                                ON alphabeth_names.describable_id = alphabeths.id
                               AND alphabeth_names.describable_type = 'Subject'
                                   #{alph_wheres&.first}
                             WHERE appellations.id IS NOT NULL
                               AND (appellations.describable_id = #{as}.id
                               AND appellations.describable_type = '#{model}'
                               AND appellations.type IN ('Appellation')
                                   #{kind_where}) #{lang_wheres&.last} #{alph_wheres&.last}
                          GROUP BY appellations.id, appellations.describable_type, appellations.text,
                                   language_names.text, alphabeth_names.text)
                            SELECT jsonb_agg(__appellations)
                              FROM __appellations), '[]'::jsonb) AS _appellations"

            # binding.pry
            select(selector).group(:id)
         end

         scope :with_appellation, -> context do
            this = table.table_alias || table.name
            language_codes = context[:language] ? [context[:language]] : context[:text_languages]
            alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
            /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
            as = context[:as] || model.reflections[rela]&.name || rela
            selector = self.select_values.dup
            selector << "#{this}.*" if selector.empty?
            selector << "#{this}_appellations.text AS _appellation"

            join = "LEFT OUTER JOIN descriptions AS #{this}_appellations
                                 ON #{this}_appellations.describable_id = #{this}.id
                                AND #{this}_appellations.describable_type = '#{model}'
                                AND #{this}_appellations.type IN ('Appellation')
                                AND #{this}_appellations.language_code IN ('#{language_codes.join("', '")}')
                                AND #{this}_appellations.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

            joins(join).select(selector.uniq).group('_appellation', "#{this}.id")
         end

         accepts_nested_attributes_for :appellations, reject_if: :all_blank, allow_destroy: true

         validates :appellations, associated: true

         before_validation :fill_in_appellation

         def appellation_language
           @appellation_language ||= appellations.last&.language.name
         end

         def appellation_alphabeth
            @appellation_alphabeth ||= appellations.last&.alphabeth.name
         end

         def appellation_language_code
            @appellation_language ||= appellations.last&.language_code
         end

         def appellation_alphabeth_code
            @appellation_alphabeth_code ||= appellations.last&.alphabeth_code
         end

         def fill_in_appellation
            if @appellation
               lc_pre = appellation_language_code || @language_code
               ac_pre = appellation_alphabeth_code || @alphabeth_code
               lc, ac = Languageble.la_for_string(@appellation, lc_pre, ac_pre)

               if appellation = appellations.where(language_code: lc, alphabeth_code: ac).first
                  appellation.update_attribute(:text, @appellation)
               else
                  appellations << Appellation.new(text: @appellation, language_code: lc, alphabeth_code: ac)
               end
            end
         end
      end
   end
end
