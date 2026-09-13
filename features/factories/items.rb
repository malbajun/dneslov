FactoryBot.define do
   factory :item do
      sequence(:id, 0)

      transient do
         title { 'Текст' }
         description { 'Текст' }
         item_type_title { nil }
      end

      after(:build) do |o, e|
         o.item_type =
            if e.item_type_title.present?
               find_build(:item_type, title: e.item_type_title)
            else
               build(:item_type)
            end
         if e.title.present?
            o.titles = build_list(:title, 1,
               describable: o,
               text: e.title,
               alphabeth_code: :РУ,
               language_code: :ру)
         end
         if e.description.present?
            o.descriptions = build_list(:description, 1,
               describable: o,
               text: e.description,
               alphabeth_code: :РУ,
               language_code: :ру)
         end
      end
   end
end
