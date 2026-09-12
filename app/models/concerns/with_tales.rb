module WithTales
   extend ActiveSupport::Concern

   def self.included base
      base.class_eval do
         attr_writer :tale, :tale_language, :tale_alphabeth, :tale_language_code, :tale_alphabeth_code

         has_many :tales, as: :describable, class_name: :Tale, dependent: :delete_all
         has_many :default_tales, -> { distinct }, through: :kind, source: :names, class_name: :Appellation

         scope :by_tale, ->(tale) do
            this = table.table_alias || table.name
            as = "by_tale_#{this}"

            join = "LEFT JOIN descriptions AS #{as}_tales
                           ON #{as}_tales.describable_id = #{this}.id
                          AND #{as}_tales.describable_type = '#{model}'
                          AND #{as}_tales.type IN ('Tale')"

            joins(join).where("unaccent(#{as}_tales.text) = unaccent(?)", tale)
         end

         scope :a_tale, ->(tale) do
            this = table.table_alias || table.name
            as = "a_tale_#{this}"

            join = "LEFT JOIN descriptions AS #{as}_tales
                           ON #{as}_tales.describable_id = #{this}.id
                          AND #{as}_tales.describable_type = '#{model}'
                          AND #{as}_tales.type IN ('Tale')"

            joins(join).where("unaccent(#{as}_tales.text) ~* unaccent(?)", tale)
         end

         scope :with_tales, -> context do
            as = table.table_alias || table.name
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
                               "OR tales.describable_id = #{as}_kinds.id
                               AND tales.describable_type = 'Subject'
                               AND tales.type IN ('Tale')"
            end

            if language_codes.any?
               lang_wheres = [
                  "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
                  "AND tales.language_code IN ('#{language_codes.join("', '")}')"
               ]
            end

            if alphabeth_codes.any?
               alph_wheres = [
                  "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
                  "AND tales.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
               ]
            end

            selector << "COALESCE((WITH __tales AS (
                            SELECT DISTINCT ON(tales.id)
                                   tales.id AS id,
                                   tales.type AS type,
                                   tales.text AS text,
                                   tales.language_code AS language_code,
                                   tales.alphabeth_code AS alphabeth_code,
                                   language_names.text AS language,
                                   alphabeth_names.text AS alphabeth
                              FROM descriptions AS tales
                                   #{kind_join}
                   LEFT OUTER JOIN subjects AS languages
                                ON languages.key = tales.language_code
                   LEFT OUTER JOIN descriptions AS language_names
                                ON language_names.describable_id = languages.id
                               AND language_names.describable_type = 'Subject'
                                   #{lang_wheres&.first}
                   LEFT OUTER JOIN subjects AS alphabeths
                                ON alphabeths.key = tales.alphabeth_code
                   LEFT OUTER JOIN descriptions AS alphabeth_names
                                ON alphabeth_names.describable_id = alphabeths.id
                               AND alphabeth_names.describable_type = 'Subject'
                                   #{alph_wheres&.first}
                             WHERE tales.id IS NOT NULL
                               AND (tales.describable_id = #{as}.id
                               AND tales.describable_type = '#{model}'
                               AND tales.type IN ('Tale')
                                   #{kind_where}) #{lang_wheres&.last} #{alph_wheres&.last}
                          GROUP BY tales.id, tales.describable_type, tales.text,
                                   language_names.text, alphabeth_names.text)
                            SELECT jsonb_agg(__tales)
                              FROM __tales), '[]'::jsonb) AS _tales"

            # binding.pry
            select(selector).group(:id)
         end

         scope :with_tale, -> context do
            this = table.table_alias || table.name
            language_codes = context[:language] ? [context[:language]] : context[:text_languages]
            alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
            /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
            as = context[:as] || model.reflections[rela]&.name || rela
            selector = self.select_values.dup
            selector << "#{this}.*" if selector.empty?
            selector << "#{this}_tales.text AS _tale"

            join = "LEFT OUTER JOIN descriptions AS #{this}_tales
                                 ON #{this}_tales.describable_id = #{this}.id
                                AND #{this}_tales.describable_type = '#{model}'
                                AND #{this}_tales.type IN ('Tale')
                                AND #{this}_tales.language_code IN ('#{language_codes.join("', '")}')
                                AND #{this}_tales.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

            joins(join).select(selector.uniq).group('_tale', "#{this}.id")
         end

         accepts_nested_attributes_for :tales, reject_if: :all_blank, allow_destroy: true

         validates :tales, associated: true

         before_validation :fill_in_tale

         def tale_language
            @tale_language ||= tales.last&.language.name
         end

         def tale_alphabeth
            @tale_alphabeth ||= tales.last&.alphabeth.name
         end

         def tale_language_code
            @tale_language ||= tales.last&.language_code
         end

         def tale_alphabeth_code
            @tale_alphabeth_code ||= tales.last&.alphabeth_code
         end

         def fill_in_tale
            if @tale
               lc_pre = tale_language_code || @language_code
               ac_pre = tale_alphabeth_code || @alphabeth_code
               lc, ac = Languageble.la_for_string(@tale, lc_pre, ac_pre)

               if tale = tales.where(language_code: lc_pre || lc, alphabeth_code: ac_pre || ac).first
                  tale.update_attribute(:text, @tale)
               else
                  tales << Tale.new(text: @tale, language_code: lc_pre || lc, alphabeth_code: ac_pre || ac)
               end
            end
         end
      end
   end
end
