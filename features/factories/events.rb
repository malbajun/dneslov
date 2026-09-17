FactoryBot.define do
   factory :event do
      happened_at { Date.today.to_s }
      language_code { nil }
      alphabeth_code { nil }

      transient do
         without_roles { nil }
         without_place { nil }
         place_short_name { nil }
         item_id { nil }
      end

      transient do
         kind { Subject.where(kind_code: "EventKind").first }
      end

      after(:build) do |o, e|
         o.kind = e.kind || build(:event_kind) unless o.kind_code
         o.item = find_build(:item, id: e.item_id) if e.item_id
         o.place =
            if e.place_short_name
               find_build(:place, short_name: e.place_short_name, without_place: true, without_events: true)
            else
               find_build(:place, without_place: true, without_events: true)
            end
      end
   end
end
