FactoryBot.define do
   factory :event do
      happened_at { Date.today.to_s }
      language_code { nil }
      alphabeth_code { nil }

      association :item
      place factory: :place, without_place: true, without_events: true

      transient do
         without_place { nil }
      end

      transient do
         kind { Subject.where(kind_code: "EventKind").first }
      end

      after(:build) do |o, e|
         o.kind = e.kind || association(:event_kind) unless o.kind_code
         o.memory = build(:memory, without_events: true) unless o.memory
      end
   end
end
