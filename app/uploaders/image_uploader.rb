class ImageUploader < CarrierWave::Uploader::Base
   include ::CarrierWave::Backgrounder::Delay
   include ::CarrierWave::MiniMagick
   include FramedThumbnail
   include TiffConversion
   include AnimationProcessing

   cache_storage CarrierWave::Storage::File
   storage :file

   process convert: 'webp'
   process :auto_orient

   version :thumb do
      process thumbnail: [400,400]
   end

   def store_dir
      "images/#{model.uid[0]}/#{model.uid[0..1]}"
   end

   def cache_dir
      "cache/carrierwave"
   end

   # If you upload 'file.jpg', you'll get 'image.webp' because of convert
   def filename
      "#{model.uid}.#{file.extension}"
   end

   def content_type_allowlist
      [/image\//]
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
