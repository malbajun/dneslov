FactoryBot.define do
   factory :rite do
      transient do
         #title { FFaker::NameRU.name }
         #description { FFaker::NameRU.name }
      end

      bind_kind_rite { 'несвязан' }
      abbreviation { FFaker::NameRU.first_name }
      text { Faker::Lorem.paragraph }
      language_code { Languageble.la_for_string(text).first }
      alphabeth_code { Languageble.la_for_string(text).last }
      title { FFaker::NameRU.name }
      description { FFaker::NameRU.name }

      after(:build) do |o, e|
         #o.titles << build(:title, text: e.title)
         #o.descriptions << build(:description, text: e.description)
      end
   end
end
