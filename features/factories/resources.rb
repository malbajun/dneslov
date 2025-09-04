FactoryBot.define do
   factory :resource do
      path { "" }
      props { {} }
      data { "" }
      type { "Resource" }
      resource { resource_path ? Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, resource_path))) : nil }

      transient do
         resource_path { nil }
      end

      after(:build) do |o, e|
      end
   end

   factory :book, parent: :resource do
      type { "Resource::Book" }

      transient do
         resource_path { 'features/fixtures/book.djvu' }
      end
   end

   factory :page_set, parent: :resource do
      type { "Resource::PageSet" }
      resource { resource_path ? IO.read(resource_path) : nil }

      transient do
         resource_path { 'features/fixtures/book.html' }
      end
   end

   factory :pictura, parent: :resource do
      type { "Resource::Pictura" }

      transient do
         resource_path { 'features/fixtures/y2000-cyan.webp' }
      end

   end

   factory :site, parent: :resource do
      type { "Resource::Site" }
      resource { resource_path ? IO.read(resource_path) : nil }

      transient do
         resource_path { 'features/fixtures/book.html' }
      end
   end

   factory :sonus, parent: :resource do
      type { "Resource::Sonus" }

      transient do
         resource_path { 'features/fixtures/hey_cartoon.mp3' }
      end
   end

   factory :virtual, parent: :resource do
      type { "Resource::Virtual" }
      resource { resource_path ? resource_path : nil }

      transient do
         resource_path { 'data' }
      end
   end

   factory :volumen, parent: :resource do
      type { "Resource::Volumen" }
      resource { resource_path ? resource_path : nil }

      transient do
         resource_path { 'data' }
      end
   end
end
