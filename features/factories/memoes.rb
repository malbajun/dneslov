FactoryBot.define do
   factory :memo do
      calendary { build(:calendary) }
      event { build(:event) }
      year_date { "10.10%6" }

      transient do
         calendary_uno { nil }
         event_name { nil }
         title { nil }
         order_slug { nil }
         note { nil }
         council_title { nil }
      end

      after(:build) do |memo, e|
         if e.event_name.present?
            e.event = Event.by_uno(e.event_name).first
         end

         if e.title.present?
            e.titles << build(:title, text: e.title)
         end

         if e.order_slug.present?
            e.order = Order.by_uno(e.order_slug).first || build(:order, slug: e.order_slug)
         end

         if e.note.present?
            e.notes << build(:note, text: e.note)
         end

         if e.calendary_uno.present?
            memo.calendary = Calendary.by_uno(e.calendary_uno).first
         end

         if e.council_title.present?
            if memo.bond_to = Memo.by_title(e.council_title).first
               memo.year_date = nil
               memo.bind_kind_code = 'соборный'
            end
         end
      end
   end
end
