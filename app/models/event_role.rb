class EventRole < ApplicationRecord
   belongs_to :event
   belongs_to :memory
end
