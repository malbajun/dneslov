class RoundelUploader < CarrierWave::Uploader::Base
   include ::CarrierWave::Backgrounder::Delay
   include CarrierWave::RMagick

   cache_storage CarrierWave::Storage::File
   storage :file

   process convert: 'webp'
   process resize_to_fit: [400, 400], if: :match_size?

   def store_dir
      "roundels/#{model.uid[0..1]}"
   end

   def cache_dir
      "cache/carrierwave"
   end

   def match_size? file
      height >= 400 if file
   end

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
