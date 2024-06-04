class User < ApplicationRecord
   include Tiun::Model::Auth
   include WithDescriptions

   has_one :email, class_name: "Account::Email"
   has_one :session_token, class_name: "Token::Session", as: :tokenable
   has_one :refresh_token, class_name: "Token::Refresh", as: :tokenable
   has_many :session_tokina, class_name: "Token::Session", as: :tokenable
   has_many :refresh_tokina, class_name: "Token::Refresh", as: :tokenable
   has_many :user_names, dependent: :destroy
   has_many :nomina, through: :user_names
   has_many :members, dependent: :destroy
   has_many :roles, through: :members

   before_validation :fill_in_account

   validates_presence_of :accounts
   validates_presence_of :user_names, if: ->{ self.default_name.blank? && !self.password }
   accepts_nested_attributes_for :accounts, :user_names

   scope :by_accounts, ->(hash) do
      rela =
         hash.reduce(Account.where(Arel.sql("FALSE"))) do |rela, (type, no)|
            rela.or(Account.where(no: no, type: type))
         end

      joins(:accounts).merge(rela).distinct
   end

   scope :by_uno, ->(uno) do
      if /^\d+$/ =~ uno
         where(self.primary_key => uno)
      else
         joins(:accounts).where(accounts: { no: uno })
      end
   end

   scope :with_user_names, -> context do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      attrs = context[:only] || self.model.attribute_names
      as = model.reflections[rela]&.name || "user_names"
      language_codes = [context[:text_languages]].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE((
                        WITH __#{as} AS (
                      SELECT #{as}.id AS id,
                             nomina.id AS nomen_id,
                             names.text || COALESCE(' < ' || bond_toes.text, '') || ' (' || names.language_code|| '_' || names.alphabeth_code || ')' AS name,
                             #{as}.kind AS kind,
                             #{as}.way AS way,
                             #{as}.usage AS usage,
                             #{as}.source AS source,
                             #{as}.main AS main
                        FROM #{as}
             LEFT OUTER JOIN nomina
                          ON nomina.id = #{as}.nomen_id
             LEFT OUTER JOIN names
                          ON names.id = nomina.name_id
             LEFT OUTER JOIN names AS bond_toes
                          ON bond_toes.id = nomina.bond_to_id
                       WHERE #{as}.#{this.singularize}_id = #{this}.id
                         AND #{as}.id IS NOT NULL
                    GROUP BY #{as}.id, names.text, bond_toes.text, names.language_code, names.alphabeth_code, nomina.id)
                      SELECT jsonb_agg(__#{as})
                        FROM __#{as}), '[]'::jsonb) AS _#{as}"

      select(selector).group(:id)
   end

   scope :with_names, -> (context) do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      attrs = context[:only] || self.model.attribute_names
      #binding.pry
      as = "user_names"#model.reflections[rela].name
      language_codes = [context[:text_languages]].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE((
              WITH RECURSIVE __names(level,path,id,name_id,name_bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,kind,usage,way,source,main) AS (
              WITH RECURSIVE tt(level,path,id,name_id,bind_kind_name,bond_to_id,root_id,name_alphabeth_code,name_language_code,name_text,kind,usage,way,source,main) AS (
                      SELECT 0,
                             nm.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             nm.alphabeth_code,
                             nm.language_code,
                             nm.text,
                             un.kind,
                             un.usage,
                             un.way,
                             un.source,
                             un.main
                        FROM nomina n
                        JOIN names nm
                          ON nm.id = n.name_id
                        JOIN #{as} un
                          ON un.nomen_id = n.id
                         AND un.#{this.singularize}_id = #{this}.id
                       UNION

                      SELECT 0,
                             nm.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             nm.alphabeth_code,
                             nm.language_code,
                             nm.text,
                             tt.kind,
                             tt.usage,
                             tt.way,
                             tt.source,
                             tt.main
                        FROM nomina n
                        JOIN tt
                          ON n.root_id = tt.root_id AND tt.bond_to_id = n.name_id
                        JOIN names nm
                          ON nm.id = n.name_id
                        JOIN names nm_t
                          ON nm_t.id = tt.name_id
                         AND nm_t.language_code <> nm.language_code
             LEFT OUTER JOIN #{as} un
                          ON n.root_id = un.nomen_id
                         AND un.#{this.singularize}_id = #{this}.id)
                      SELECT *
                        FROM tt

                       UNION
                      SELECT level + 1,
                             path || ' > ' || nm.text,
                             n.id,
                             n.name_id,
                             n.bind_kind_name,
                             n.bond_to_id,
                             n.root_id,
                             nm.alphabeth_code,
                             nm.language_code,
                             nm.text,
                             t.kind,
                             t.usage,
                             t.way,
                             t.source,
                             t.main
                        FROM nomina n
                        JOIN __names t
                          ON n.bond_to_id = t.name_id
                         AND n.root_id = t.root_id
                        JOIN names nm
                          ON nm.id = n.name_id
                        JOIN names nm_t
                          ON nm_t.id = t.name_id
                         AND nm_t.language_code <> nm.language_code
             LEFT OUTER JOIN #{as} un
                          ON n.root_id = un.nomen_id
                         AND un.#{this.singularize}_id = #{this}.id)
                      SELECT jsonb_agg(__names)
                        FROM __names
                       WHERE __names.name_language_code IN ('#{language_codes.join("', '")}')), '[]'::jsonb) AS _user_names"

      binding.pry
      select(selector).group(:id)
   end

   scope :with_accounts, ->(context) do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = model.reflections[rela].name
      attrs = context[:only] || model.reflections[rela].klass.attribute_names
      selects = attrs.map { |x| "#{as}.#{x} AS #{x}" }
      groups = attrs.map { |x| "#{as}.#{x}" }

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE((WITH __#{as} AS (
                      SELECT #{selects.join(",")}
                        FROM #{as}
                       WHERE #{this}.id = #{as}.#{this.singularize}_id
                    GROUP BY #{groups.join(",")})
                      SELECT jsonb_agg(__#{as})
                        FROM __#{as}), '[]'::jsonb) AS _#{as}"

      select(selector).group(:id)
   end

   def uid
      [accounts.first&.no, accounts.first&.type].join("#")
   end

   def no= value
      @no = value
   end

   def type= value
      @type = value
   end

   def name
      # name or email
      email.no
   end

   def permissions
      roles.pluck(:permissions).flatten.uniq
   end

   def fill_in_account
      if @no or @type
         attrs = {}
         attrs[:no] = @no if @no
         attrs[:type] = @type if @type

         if @type && account = accounts.where(type: @type).first
            account.assign_attributes(**attrs)
            account.save!(validate: false)
         else
            accounts << Account.new(**attrs)
         end
      end
   end
end
