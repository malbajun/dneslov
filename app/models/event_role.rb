class EventRole < ApplicationRecord
   belongs_to :event
   belongs_to :memory

   has_many :hymnable_scripta, as: :hymnable, dependent: :destroy
   has_many :memoes, dependent: :nullify
end
