class BookUploader < CarrierWave::Uploader::Base
   include ::CarrierWave::Backgrounder::Delay
   include ::CarrierWave::MiniMagick
   include FramedThumbnail

   cache_storage CarrierWave::Storage::File
   storage :file

   #process convert: 'djvu'

   version :thumb do
      storage :file

      process :convert => 'webp' # this should do the trick but doesn't
      process thumbnail: [400,400]
      process :set_content_type

      def filename
         "thumb_#{model.uid}.webp"
      end
   end

   def store_dir
      "books/#{model.uid[0]}/#{model.uid[0..1]}"
   end

   def cache_dir
      "cache/carrierwave"
   end

   def filename
      "#{model.uid}.#{file.extension}"
   end

   def content_type_allowlist
      [/application\/pdf/, /application\/djvu/]
   end

   def set_content_type *_args
      self.file.instance_variable_set(:@content_type, "image/webp")
   end

   def asset_host
      self.class.asset_host
   end

   class << self
      def asset_host
         case h = Rails.application.config.asset_host
         when Proc
            h[]
         when String, Symbol
            h
         else
            nil
         end
      end
   end
end
