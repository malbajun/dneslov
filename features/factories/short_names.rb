FactoryBot.define do
   factory :short_name do
      text { FFaker::NameRU.name }
      language_code { Languageble.la_for_string(text).first }
      alphabeth_code { Languageble.la_for_string(text).last }
      association :memory
   end
end
