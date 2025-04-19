FactoryBot.define do
   factory :order, parent: :memory, class: :Order do
      type { 'Order' }

      transient do
         order { 'ЧинЧин' }
      end

      after(:build) do |o, e|
         #o.descriptions << build(:description) if o.descriptions.blank?
         o.notes << build(:note, text: e.order) if e.order
         o.tweets << build(:tweet, text: e.slug) if e.slug
      end
   end
end
