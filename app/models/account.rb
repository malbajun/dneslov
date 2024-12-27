class Account < ApplicationRecord
   include Tiun::Model::Account

   has_many :session_tokina, class_name: "Token::Session", as: :tokenable
   has_many :refresh_tokina, class_name: "Token::Refresh", as: :tokenable

   validates :no, uniqueness: { scope: :type }

   scope :by_credentials_or_id, ->(croi) do
      joins(:user).where(no: croi)
      # joins(:user).where(no: croi).or(where("users.settings @> ?", "{\"name\": \"#{croi}\"}"))
   end

   def validated
      false
   end
end
