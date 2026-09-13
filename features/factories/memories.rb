FactoryBot.define do
   factory :memory do
      base_year { FFaker::Number.number }

      transient do
         without_place { nil }
         without_events { nil }
         short_name { nil }
         language_code { Languageble.la_for_string(short_name).first }
         alphabeth_code { Languageble.la_for_string(short_name).last }
      end

      after(:build) do |m, e|
         opts = {}
         if e.without_place
            opts[:place] = nil
            opts[:without_place] = true
         end

         if e.short_name
            m.short_names =
               build_list(:short_name, 1,
                  text: e.short_name,
                  language_code: e.language_code,
                  alphabeth_code: e.alphabeth_code,
                  memory: m)
         end
         m.events << build(:event, memory: m, **opts) unless e.without_events
         m.slug = e.slug.is_a?(String) ? build(:slug, text: e.slug) : e.slug if e.slug
      end
   end

   factory :place, parent: :memory, class: :Place do
      type { 'Place' }

      transient do
         description { FFaker::NameRU.name }
      end

      after(:build) do |place, e|
         if e.description.present?
            language_code, alphabeth_code = Languageble.la_for_string(e.description)
            place.descriptions = build_list(:description, 1,
               describable: place,
               text: e.description,
               alphabeth_code: alphabeth_code,
               language_code: language_code)
         end
      end
   end

   factory :order, parent: :memory, class: :Order do
      type { 'Order' }

      transient do
         order { 'ЧинЧин' }
      end

      after(:build) do |o, e|
         o.notes << build(:note, text: e.order) if e.order
         o.tweets << build(:tweet, text: e.slug) if e.slug
      end
   end
end
