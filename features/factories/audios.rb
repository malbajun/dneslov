FactoryBot.define do
   factory :audio do
      uid { Faker::Internet.uuid }
      kind { "Audio" }
      meta { {} }

      transient do
         memory_title { nil }
         event_title { nil }
         audio_path { 'features/fixtures/hey_cartoon.mp3' }
      end

      audio { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, audio_path))) }
      attitude_to { nil }

      after(:build) do |o, e|
         o.memories << Memory.by_short_name(e.memory_title).first || build(:memory, short_name: e.memory_title) if e.memory_title
         o.events << Event.by_title(e.event_title).first || build(:event, title: e.event_title) if e.event_title
      end
   end
end
