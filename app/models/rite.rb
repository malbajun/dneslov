class Rite < ActiveRecord::Base
   extend TotalSize
   include DistinctBy
   include Tokens
   include Languageble
   include WithLocaleNames
   include WithTitles
   include WithDescriptions
   include ByToken

   has_many :tied_to, class_name: :Rite, foreign_key: :bond_to_id

   belongs_to :bind_kind, primary_key: :key, foreign_key: :bind_kind_rite, class_name: :Subject
   belongs_to :bond_to, primary_key: :id, foreign_key: :bond_to_id, class_name: :Rite
   belongs_to :root, primary_key: :id, foreign_key: :root_id, class_name: :Rite

   default_scope { order(updated_at: :desc) }

   scope :by_token, -> text do
      this = table.table_alias || table.name
      where("unaccent(rites.text) ~* unaccent(?)", "\\m#{text}.*")
         .or(Rite.where("unaccent(rites.abbreviation) ~* unaccent(?)", "\\m#{text}.*"))
   end

   # by universal numbering object: by id, by abbreviation or by title
   scope :by_uno, ->(uno) do
      case uno
      when /^\s*$/
         none
      when /^\d+$/
         where(id: uno)
      else
         by_abbreviation_or_title(uno)
      end
   end

   # title with or without event
   scope :by_abbreviation_or_title, ->(title) do
      self.by_title(title).or(Rite.where(abbreviation: title)).distinct
   end

   scope :with_key, -> _ do
      this = table.table_alias || table.name
      selector = self.select_values.dup | ["#{this}.id AS _key"]

      select(selector).group('_key').reorder("_key")
   end

   scope :with_value, -> context do
      this = table.table_alias || table.name

      selector = self.select_values.dup |
        [["(#{this}.abbreviation",
          "' ('",
          "#{this}.language_code",
          "'_'",
          "#{this}.alphabeth_code",
          "')'",
          "COALESCE(' << '",
          "#{this}_bond_toes.abbreviation",
          "' ('",
          "#{this}_bond_toes.language_code",
          "'_'",
          "#{this}_bond_toes.alphabeth_code",
          "')', '')) AS _value"].join(" || ")]

      join = "LEFT OUTER JOIN rites AS #{this}_bond_toes
                           ON #{this}.bond_to_id = #{this}_bond_toes.id"

      group = [
         :id,
         "#{this}.abbreviation",
         "#{this}.language_code",
         "#{this}.alphabeth_code",
         "#{this}_bond_toes.abbreviation",
         "#{this}_bond_toes.language_code",
         "#{this}_bond_toes.alphabeth_code"
      ]

      joins(join).select(selector).group(*group)
   end

   scope :with_root_rite, -> context do
      this = table.table_alias || table.name

      selector = self.select_values.dup
      selector << "#{this}.*" if self.select_values.dup.empty?
      selector << "root_#{this}.abbreviation || ' (' || root_#{this}.language_code || '_' || root_#{this}.alphabeth_code || ')' AS _root_rite"

      join = "LEFT OUTER JOIN #{this} AS root_#{this}
                           ON root_#{this}.id = #{this}.root_id"

      joins(join).select(selector).group(:id, "root_#{this}.abbreviation", "root_#{this}.language_code", "root_#{this}.alphabeth_code")
   end

   scope :with_bond_to_rite, -> context do
      this = table.table_alias || table.name

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "bond_to_#{this}.abbreviation || ' (' || bond_to_#{this}.language_code || '_' || bond_to_#{this}.alphabeth_code || ')' AS _bond_to_rite"

      join = "LEFT OUTER JOIN #{this} AS bond_to_#{this}
                           ON bond_to_#{this}.id = #{this}.bond_to_id"

      joins(join).select(selector).group(:id, "bond_to_#{this}.abbreviation", "bond_to_#{this}.language_code", "bond_to_#{this}.alphabeth_code")
   end

   scope :with_bind_kind_rite, -> context do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      ast = as.to_s.tableize
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{ast}.text AS _bind_kind_humanized"

      join = "LEFT OUTER JOIN subjects AS rite_bind_kinds
                           ON rite_bind_kinds.kind_code = 'RiteBind'
                          AND rite_bind_kinds.key = #{this}.bind_kind_rite
              LEFT OUTER JOIN descriptions AS #{ast}
                           ON #{ast}.describable_id = rite_bind_kinds.id
                          AND #{ast}.describable_type = 'Subject'
                          AND #{ast}.language_code IN ('#{language_codes.join("', '")}')
                          AND #{ast}.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "_bind_kind_humanized")
   end

   scope :with_bond_to_uno, -> context do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "bond_to_#{this}_#{as}.abbreviation AS _bond_to_uno"

      join = "LEFT OUTER JOIN #{this} AS bond_to_#{this}_#{as}
                           ON bond_to_#{this}_#{as}.id = #{this}.bond_to_id"

      joins(join).select(selector).group(:id, "bond_to_#{this}_#{as}.abbreviation")
   end

   scope :with_root_uno, -> context do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "root_#{this}_#{as}.abbreviation AS _root_uno"

      join = "LEFT OUTER JOIN #{this} AS root_#{this}_#{as}
                           ON root_#{this}_#{as}.id = #{this}.root_id"

      joins(join).select(selector).group(:id, "root_#{this}_#{as}.abbreviation")
   end

   scope :by_root, -> do
      model.where(root_id: self.select(:root_id))
   end

   singleton_class.send(:alias_method, :t, :by_token)

   validates_presence_of :bind_kind, :abbreviation
   validates_presence_of :bond_to_id, if: :bond?
   validates_absence_of :bond_to_id, unless: :bond?
   validates_uniqueness_of :id, :abbreviation

   before_validation -> { self.bind_kind_rite ||= 'несвязан' }, on: :create

   def bond?
      bind_kind_rite != 'несвязан'
   end
end
