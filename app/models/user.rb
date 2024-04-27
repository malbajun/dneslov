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

   before_validation :fill_in_account

   validates_presence_of :accounts
   accepts_nested_attributes_for :accounts

   scope :by_accounts, ->(hash) do
      rela =
         hash.reduce(Account.where(Arel.sql("FALSE"))) do |rela, (type, no)|
            rela.or(Account.where(no: no, type: type))
         end

      joins(:accounts).merge(rela).distinct
   end

   scope :by_uno, ->(uno) do
      joins(:accounts).where(accounts: { no: uno })
   end

   scope :with_accounts, ->(context) do
      this = table.table_alias || table.name
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      attrs = context[:only] || self.model.attribute_names
      as = model.reflections[rela].name
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
