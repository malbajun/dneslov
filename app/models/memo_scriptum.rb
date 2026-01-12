class MemoScriptum < ApplicationRecord
   belongs_to :scriptum
   belongs_to :memo
   belongs_to :event
   has_one :memory, through: :event

   validates :kind, inclusion: { in: %w(To From About Author Translator) }
end
