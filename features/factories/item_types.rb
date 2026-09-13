FactoryBot.define do
   factory :item_type do
      transient do
         item_description { 'Текст' }
      end

      after(:build) do |o, e|
         if e.item_description.present? && o.descriptions.blank?
            o.descriptions =
               build_list(:description, 1,
                  describable: o,
                  text: e.item_description,
                  alphabeth_code: :РУ,
                  language_code: :ру)
         end
      end
   end
end
