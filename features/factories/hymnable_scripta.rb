FactoryBot.define do
   factory :hymnable_scriptum do
      transient do
         memory_short_name { nil }
      end

      after(:build) do |o, e|
         o.hymnable =
            if e.memory_short_name
               find_build(:memory, short_name: e.memory_short_name)
            else
               build(:memory)
            end
      end
   end
end
