class Account < ApplicationRecord
   include Tiun::Model::Account

   self.primary_key = "no"

   has_many :session_tokina, class_name: "Token::Session", as: :tokenable
   has_many :refresh_tokina, class_name: "Token::Refresh", as: :tokenable

   validates :no, uniqueness: { scope: :type }

   scope :by_credentials_or_primary_key, ->(cropk) do
      joins(:user).where(no: cropk)
      # joins(:user).where(no: croi).or(where("users.settings @> ?", "{\"name\": \"#{croi}\"}"))
   end
end
