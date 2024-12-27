module WithNotes
   extend ActiveSupport::Concern

   def self.included base
      base.class_eval do
         has_many :notes, as: :describable, class_name: :Note, dependent: :delete_all
         has_many :default_notes, -> { distinct }, through: :kind, source: :names, class_name: :Appellation
         has_many :all_notes, ->(this) do
            where(describable_type: model.name, describable_id: this.id, kind: "Note")
              .or( Appellation.merge(this.kind.names)).order(:describable_type)
         end, primary_key: nil, class_name: :Description

         scope :by_note, -> note do
            this = table.table_alias || table.name
            as = "by_note_#{this}"

            join = "LEFT JOIN descriptions AS #{as}_notes
                           ON #{as}_notes.describable_id = #{this}.id
                          AND #{as}_notes.describable_type = '#{model}'
                          AND #{as}_notes.type IN ('Note', 'Appellation')"

            joins(join).where("#{as}_notes.text ~* ?", note)
         end

         scope :with_notes, -> context do
            as = table.table_alias || table.name
            language_codes = [context[:text_languages]].flatten.compact
            alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
            selector = self.select_values.dup
            selector << "#{model.table_name}.*" if selector.empty?

            if self.model.attribute_names.include?("kind_code")
               kind_join =
                  "LEFT OUTER JOIN subjects AS #{as}_kinds
                                ON #{as}_kinds.kind_code = '#{model.name}Kind'
                               AND #{as}_kinds.key = #{as}.kind_code"
               kind_where =
                               "OR notes.describable_id = #{as}_kinds.id
                               AND notes.describable_type = 'Subject'
                               AND notes.type IN ('Note', 'Appellation')"
            end

            if language_codes.any?
               lang_wheres = [
                  "AND language_names.language_code IN ('#{language_codes.join("', '")}')",
                  "AND notes.language_code IN ('#{language_codes.join("', '")}')"
               ]
            end

            if alphabeth_codes.any?
               alph_wheres = [
                  "AND alphabeth_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')",
                  "AND notes.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
               ]
            end

            selector << "COALESCE((WITH __notes AS (
                            SELECT DISTINCT ON(notes.id)
                                   notes.id AS id,
                                   notes.type AS type,
                                   notes.text AS text,
                                   notes.language_code AS language_code,
                                   notes.alphabeth_code AS alphabeth_code,
                                   language_names.text AS language,
                                   alphabeth_names.text AS alphabeth
                              FROM descriptions AS notes
                                   #{kind_join}
                   LEFT OUTER JOIN subjects AS languages
                                ON languages.key = notes.language_code
                   LEFT OUTER JOIN descriptions AS language_names
                                ON language_names.describable_id = languages.id
                               AND language_names.describable_type = 'Subject'
                                   #{lang_wheres&.first}
                   LEFT OUTER JOIN subjects AS alphabeths
                                ON alphabeths.key = notes.alphabeth_code
                   LEFT OUTER JOIN descriptions AS alphabeth_names
                                ON alphabeth_names.describable_id = alphabeths.id
                               AND alphabeth_names.describable_type = 'Subject'
                                   #{alph_wheres&.first}
                             WHERE notes.id IS NOT NULL
                               AND (notes.describable_id = #{as}.id
                               AND notes.describable_type = '#{model}'
                               AND notes.type IN ('Note', 'Appellation')
                                   #{kind_where}) #{lang_wheres&.last} #{alph_wheres&.last}
                          GROUP BY notes.id, notes.describable_type, notes.text,
                                   language_names.text, alphabeth_names.text)
                            SELECT jsonb_agg(__notes)
                              FROM __notes), '[]'::jsonb) AS _notes"

            # binding.pry
            select(selector).group(:id)
         end

         scope :with_note, -> context do
            as = table.table_alias || table.name
            language_codes = [context[:text_languages]].flatten

            selector = self.select_values.dup
            selector << "#{as}.*" if selector.empty?
            selector << "#{as}_notes.text AS _note"

            join = "LEFT OUTER JOIN descriptions AS #{as}_notes
                                 ON #{as}_notes.describable_id = #{as}.id
                                AND #{as}_notes.describable_type = '#{model}'
                                AND #{as}_notes.type IN ('Note', 'Appellation')
                                AND #{as}_notes.language_code IN ('#{language_codes.join("', '")}')"

            joins(join).select(selector.uniq).group('_note', "#{as}.id")
         end

         accepts_nested_attributes_for :notes, reject_if: :all_blank, allow_destroy: true

         validates :notes, associated: true
      end
   end
end
