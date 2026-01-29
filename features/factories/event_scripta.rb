FactoryBot.define do
   factory :event_scriptum do
      scriptum { build(:scriptum) }
      event { build(:event) }
      kind { "To" }
   end
end
