class Role < ApplicationRecord
   extend TotalSize
   include WithTweets
   include WithTitles
   include WithDescriptions

   has_many :members, dependent: :destroy
   has_many :users, through: :members

   validates_presence_of :permissions

   scope :by_permission, -> permission do
      where("permissions && ?", "{̀#{permissions_in.join(',')}}")
   end

   scope :by_member, -> member do
      joins(:users).merge(User.by_uno(member))
   end

   scope :by_uno, -> uno do
      if /^\d+$/ =~ uno
         where(self.primary_key => uno)
      else
         joins(:tweets).where(tweets: { text: uno })
      end
   end

   scope :with_members, -> context do
      this = table.table_alias || table.name
      selector = self.select_values.dup
      selector << "#{this}.*" if self.select_values.dup.empty?

      selector << "COALESCE((with __members AS (
                      SELECT DISTINCT ON(account_type, account_no)
                             #{this}_names.text AS name,
                             #{this}_names.id AS name_id,
                             #{this}_accounts.no AS account_no,
                             #{this}_accounts.type AS account_type
                        FROM members
             LEFT OUTER JOIN users AS #{this}_users
                          ON #{this}_users.id = members.user_id
             LEFT OUTER JOIN accounts AS #{this}_accounts
                          ON #{this}_accounts.user_id = #{this}_users.id
             LEFT OUTER JOIN user_names AS #{this}_user_names
                          ON #{this}_user_names.user_id = #{this}_users.id
             LEFT OUTER JOIN nomina AS #{this}_nomina
                          ON #{this}_nomina.id = #{this}_user_names.nomen_id
             LEFT OUTER JOIN names AS #{this}_names
                          ON #{this}_nomina.name_id = #{this}_names.id
                       WHERE members.role_id = #{this}.id
                    GROUP BY name, #{this}_names.id, account_type, account_no)
                      SELECT jsonb_agg(__members)
                        FROM __members), '[]'::jsonb) AS _members"

      select(selector).group(:id)
   end

   scope :with_description, -> context do
      as = table.table_alias || table.name
      language_codes = [context[:text_languages]].flatten

      selector = self.select_values.dup
      selector << "#{as}.*" if selector.empty?
      selector << "#{as}_descriptions.text AS _description"

      join = "LEFT OUTER JOIN descriptions AS #{as}_descriptions
                           ON #{as}_descriptions.describable_id = #{as}.id
                          AND #{as}_descriptions.describable_type = '#{model}'
                          AND #{as}_descriptions.type IN ('Description', 'Note')
                          AND #{as}_descriptions.language_code IN ('#{language_codes.join("', '")}')"

      joins(join).select(selector.uniq).group('_description', "#{as}.id")
   end

   accepts_nested_attributes_for :members, reject_if: :all_blank, allow_destroy: true

   def permissions= value
      super(value.is_a?(String) ? JSON.parse(value) : value)
   end
end
