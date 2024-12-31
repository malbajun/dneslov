FactoryBot.define do
   factory :memory do
      short_name { FFaker::NameRU.name }
      base_year { FFaker::Number.number }

      transient do
         without_place { nil }
         without_events { nil }
      end

      after(:build) do |m, e|
         opts = {}
         if e.without_place
            opts[:place] = nil
            opts[:without_place] = true
         end

         m.events << build(:event, memory: m, **opts) unless e.without_events
         m.slug = e.slug.is_a?(String) ? build(:slug, text: e.slug) : e.slug if e.slug
      end
   end
end
