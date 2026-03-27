FactoryBot.define do
   factory :taggable do
      taggable { nil }
      tag { association :tag }
   end
end
