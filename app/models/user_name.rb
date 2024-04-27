class UserName < ApplicationRecord
   belongs_to :user
   belongs_to :nomen

   accepts_nested_attributes_for :nomen, reject_if: :all_blank

   validates_presence_of :user, :nomen, :klass

   def to_s
      nomen.text
   end
end
