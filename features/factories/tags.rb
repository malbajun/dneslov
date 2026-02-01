FactoryBot.define do
   transient do
      tweet { Faker::Superhero.name }
      title { Faker::Lorem.sentence }
      description { Faker::Lorem.sentence }
   end

   factory :tag do
      after(:build) do |m, e|
         o.descriptions << build(:description, e.description) if e.description
         o.notes << build(:title, text: e.title) if e.title
         o.tweets << build(:tweet, text: e.tweet) if e.tweet
      end
   end
end
