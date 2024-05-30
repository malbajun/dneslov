class UserName < ApplicationRecord
   belongs_to :user
   belongs_to :nomen
   belongs_to :bindable, polymorphic: true, optional: true

   accepts_nested_attributes_for :nomen, reject_if: :all_blank

   validates_presence_of :user, :nomen, :kind, :way, :usage, :source

   def to_s
      nomen.text
   end

   def name
      nomen.name.text
   end
end
