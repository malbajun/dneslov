class Member < ApplicationRecord
   belongs_to :user
   belongs_to :role

   validates_presence_of :user, :role
end
