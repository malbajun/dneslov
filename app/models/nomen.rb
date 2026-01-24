# bind_kind_name(string)  - kind of binding
# bond_to_id(int)         - id of name which the name is linked (bond) to
class Nomen < ActiveRecord::Base
   extend TotalSize
   extend Informatible
   include ByToken
   include DistinctBy
   include Languageble
   include WithDescriptions
   include WithLinks
   include WithLocaleNames

   # enum :bind_kind_name, %i(несвязаное прилаженое уменьшительное переводное подобное переложеное присвоеное унаследованное)

   has_many :memory_names
   has_many :memories, through: :memory_names
   has_many :children, class_name: :Nomen, foreign_key: :bond_to_id

   belongs_to :language, primary_key: :key, foreign_key: :language_code, class_name: :Subject
   belongs_to :alphabeth, primary_key: :key, foreign_key: :alphabeth_code, class_name: :Subject
   belongs_to :bind_kind, primary_key: :key, foreign_key: :bind_kind_name, class_name: :Subject
   belongs_to :bond_to, primary_key: :id, foreign_key: :bond_to_id, class_name: :Nomen
   belongs_to :root, primary_key: :id, foreign_key: :root_id, class_name: :Nomen

   has_alphabeth on: { text: [ :nosyntax, allow: " ‑" ] }, novalidate: true

   scope :by_token, -> text do
      this = table.table_alias || table.name
      where("unaccent(#{this}.text) ~* unaccent(?)", "\\m#{text}.*")
   end
   singleton_class.send(:alias_method, :by_query, :by_token)
   singleton_class.send(:alias_method, :t, :by_token)
   singleton_class.send(:alias_method, :q, :by_token)

   # required for short list
   scope :with_key, -> _ do
      join_name = table.table_alias || table.name
      selector = self.select_values.dup | ["#{join_name}.id AS _key"]

      select(selector).group('_key').reorder("_key")
   end

   scope :with_value, -> context do
      this = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes).flatten

      selector = self.select_values.dup |
         ["#{this}.text || ' (' ||
           #{this}.language_code || '_' ||
           #{this}.alphabeth_code || ')' ||
           COALESCE(' <~ ' || #{this}_bond_toes.text || ' (' ||
           #{this}_bond_toes.language_code || '_' ||
           #{this}_bond_toes.alphabeth_code || ')', '') AS _value"]

      join = "LEFT OUTER JOIN nomina AS #{this}_bond_toes
                           ON #{this}.bond_to_id = #{this}_bond_toes.id"

      joins(join).
         select(selector).
         group(:id,
               "#{this}.text",
               "#{this}.language_code",
               "#{this}.alphabeth_code",
               "#{this}_bond_toes.text",
               "#{this}_bond_toes.language_code",
               "#{this}_bond_toes.alphabeth_code")

   end

   scope :with_root_name, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}_root_nomina.text || ' (' || #{this}_root_nomina.language_code || '_' || #{this}_root_nomina.alphabeth_code || ')' AS _root_name"

      join = "LEFT OUTER JOIN nomina AS #{this}_root_nomina
                           ON #{this}_root_nomina.id = #{this}.root_id"

      joins(join).select(selector).group(:id,
         "#{this}_root_nomina.text",
         "#{this}_root_nomina.language_code",
         "#{this}_root_nomina.alphabeth_code")
   end

   scope :with_bond_to_name, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{this}_bond_to_nomina.text || ' (' || #{this}_bond_to_nomina.language_code || '_' || #{this}_bond_to_nomina.alphabeth_code || ')' AS _bond_to_name"

      join = "LEFT OUTER JOIN nomina AS #{this}_bond_to_nomina
                           ON #{this}_bond_to_nomina.id = #{this}.bond_to_id"

      joins(join).select(selector).group(:id,
         "#{this}_bond_to_nomina.text",
         "#{this}_bond_to_nomina.language_code",
         "#{this}_bond_to_nomina.alphabeth_code")
   end

   scope :by_root, -> do
      model.where(root_id: self.select(:root_id))
   end

   scope :with_bind_kind_name, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << 'bind_kind_names.text AS _bind_kind_humanized'

      join = "LEFT OUTER JOIN subjects AS bind_kinds
                           ON bind_kinds.kind_code = 'NameBind'
                          AND bind_kinds.key = #{this}.bind_kind_name
              LEFT OUTER JOIN descriptions AS bind_kind_names
                           ON bind_kind_names.describable_id = bind_kinds.id
                          AND bind_kind_names.describable_type = 'Subject'
                          AND bind_kind_names.language_code IN ('#{language_codes.join("', '")}')
                          AND bind_kind_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, 'bind_kind_names.text')
   end

   validates_presence_of :text, :language_code, :alphabeth_code
   validates_presence_of :bind_kind, :bind_kind_path
   validates_presence_of :bond_to_id, if: :bond?
   validates_absence_of :bond_to_id, unless: :bond?

   before_validation -> { self.bind_kind_name ||= 'несвязаное' }, on: :create
   before_validation :fill_bind_kind_path
   before_save -> { self.text = self.text.strip }
   after_save :fill_root_id, unless: :root_id?

   def bond?
      bind_kind_name != 'несвязаное'
   end

   def fill_bind_kind_path
      parent = bond_to if bond_to_id
      self.bind_kind_path = [parent&.store_bind_kind_path!, bind_kind.order].compact.join(".")
   end

   def store_bind_kind_path!
      save! if fill_bind_kind_path && changed?

      self.bind_kind_path
   end

   def fill_root_id
      new_root_id = self.bond_to&.root_id || id
      self.update!(root_id: new_root_id)
   end

   def rules= value
      super(value.is_a?(String) ? JSON.parse(value) : value)
   end
end
