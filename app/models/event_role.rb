class EventRole < ApplicationRecord
   belongs_to :event
   belongs_to :memory

   has_many :memoes, dependent: :nullify
end
