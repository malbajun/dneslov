FactoryBot.define do
   factory :roundel do
      roundelable { build(:event) }
      uid { Faker::Internet.uuid }

      transient do
         roundel_path { "features/fixtures/600x600-cyan.png" }
         short_name { nil }
         event_title { nil }
      end

      image { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, roundel_path))) }

      after(:build) do |o, e|
         o.roundelable =
            if e.event_title
               Event.by_title_and_short_name(e.event_title, e.short_name).first || build(:event, title: e.event_title)
            elsif e.short_name
               Memory.by_short_name(e.short_name) || build(:memory, short_name: e.short_name)
            else
               e.roundelable
            end

         o.roundelable_name = e.roundelable_name if e.roundelable_name
      end
   end
end
