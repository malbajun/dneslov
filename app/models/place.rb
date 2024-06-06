class Place < ActiveRecord::Base
   extend TotalSize

   has_many :descriptions, as: :describable
   has_many :events

   scope :by_token, -> text do
      left_outer_joins(:descriptions).where("unaccent(descriptions.text) ~* unaccent(?)", "\\m#{text}.*" )
   end

   singleton_class.send(:alias_method, :t, :by_token)

   accepts_nested_attributes_for :descriptions, reject_if: :all_blank, allow_destroy: true

   validates :descriptions, presence: true, associated: true

   # required for short list
   scope :with_key, -> _ do
      selector = [ "#{model.table_name}.id AS _key" ]

      select(selector).group('_key').reorder("_key")
   end

   scope :with_value, -> context do
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      selector = self.select_values.dup

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

      join = "LEFT OUTER JOIN descriptions AS titles
                           ON titles.describable_id = places.id
                          AND titles.describable_type = 'Place'
                          AND titles.type IN ('Description')
                          #{lang_wheres&.[](0)} #{alph_wheres&.[](0)}
              LEFT OUTER JOIN subjects AS languages
                           ON languages.key = titles.language_code
              LEFT OUTER JOIN descriptions AS language_names
                           ON language_names.describable_id = languages.id
                          AND language_names.describable_type = 'Order'
                          #{lang_wheres&.[](1)}
              LEFT OUTER JOIN subjects AS alphabeths
                           ON alphabeths.key = titles.alphabeth_code
              LEFT OUTER JOIN descriptions AS alphabeth_names
                           ON alphabeth_names.describable_id = alphabeths.id
                          AND alphabeth_names.describable_type = 'Order'
                          #{alph_wheres&.[](1)}"

      selector << "titles.text || ' (' || titles.language_code || '_' || titles.alphabeth_code || ')' AS _value"

      joins(join).select(selector).group(:id, "titles.text", "titles.language_code", "titles.alphabeth_code")
   end
end
