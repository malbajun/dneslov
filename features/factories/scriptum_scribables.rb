FactoryBot.define do
   factory :scriptum_scribable do
      kind { 'source' }
      scriptum
      association :scribable, factory: :audio
   end
end
