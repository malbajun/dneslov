class PicturaUploader < CarrierWave::Uploader::Base
   include ::CarrierWave::Backgrounder::Delay
   include ::CarrierWave::MiniMagick
   include FramedThumbnail
   include TiffConversion

   cache_storage CarrierWave::Storage::File
   storage :file

   process convert: 'webp'
   process :auto_orient

   version :thumb do
      process thumbnail: [400,400]
   end

   def store_dir
      "picturae/#{model.uid[0]}/#{model.uid[0..1]}"
   end

   def cache_dir
      "cache/carrierwave"
   end

   def filename
      "#{model.uid}.webp"
   end

   def content_type_allowlist
      [/image\//]
   end

   def auto_orient
      manipulate! do |img|
         img.auto_orient
         img
      end
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
