FactoryBot.define do
   factory :tag do
      tweet { Faker::Superhero.name }
      title { Faker::Lorem.sentence }
      description { Faker::Lorem.sentence }
      language_code { nil }
      alphabeth_code { nil }
   end
end
