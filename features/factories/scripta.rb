FactoryBot.define do
   factory :scriptum do
      text { Faker::Lorem.paragraph }
      language_code { :ан }
      alphabeth_code { :АН }
      type { 'Scriptum' }
      author { Faker::Superhero.name }
      description { Faker::Lorem.sentence }
      ref_title { Faker::Lorem.word }

      transient do
         hymnable_short_name { nil }
      end

      after(:build) do |o, e|
         o.hymnable_scripta << build(:hymnable_scriptum, scriptum: o, memory_short_name: e.hymnable_short_name)
      end
   end

   factory :canto, parent: :scriptum, class: :Canto do
      type { 'Canto' }
      tone { 1 }
      prosomeion_id { nil }
      title { Faker::Lorem.word }
   end

   factory :orison, parent: :canto, class: :Orison do
      type { 'Orison' }
   end

   factory :canticle, parent: :canto, class: :Canticle do
      type { 'Canticle' }
   end

   factory :chant, parent: :canticle, class: :Chant do
      type { 'Chant' }
   end
end
