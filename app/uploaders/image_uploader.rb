class ImageUploader < CarrierWave::Uploader::Base
   include ::CarrierWave::Backgrounder::Delay
   include CarrierWave::RMagick

   cache_storage CarrierWave::Storage::File
   storage :file

   process convert: 'webp'
   process :auto_orient
   process upfit: [150,1500], if: :match_size?

   version :thumb do
      process thumbnail: [400,400]
   end

   def match_size? file
      height < 1500 if file
   end

   def store_dir
      "images/#{model.uid[0..1]}"
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

   def auto_orient
      manipulate! do |img|
         img.auto_orient!
         img
      end
   end

   def thumbnail(width, height)
      width_in = dimension_from(width)
      height_in = dimension_from(height)
      ratio = self.width.to_f / self.height
      ratio_in = width.to_f / height
      width, height = ratio < ratio_in ? [width_in, height_in / ratio] : [width_in / ratio, height_in]
      geom = "#{width.to_i}x#{height.to_i}"

      manipulate! do |img|
         img.change_geometry!(geom) { |cols, rows| img.thumbnail! cols, rows }
         bg = Magick::Image.new(width + 6, height + 6) { |options| options.background_color = 'gray75' }
         bg = bg.raise(3, 3)

         # Just for the purposes of this example, display the thumbnail background on
         # a larger white background.
         white_bg = Magick::Image.new(width + 6, height + 6) { |options| options.background_color = 'gray95' }
         white_bg = white_bg.composite(bg, Magick::CenterGravity, Magick::OverCompositeOp)

         # Finally, center the thumbnail on the gray background.
         thumbnail = white_bg.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)

         destroy_image(bg)
         destroy_image(white_bg)

         thumbnail
      end
   end

   def upfit *to
      s = [to, [width, height]].transpose.map {|x| x.max }
      ro = width.to_f / height
      r = s[0].to_f / s[1]
      sizes = (ro < r ? [s[0], s[1] * r / ro] : [s[0] * ro / r, s[1]])

      manipulate! do |img|
         img.resize!(*sizes, Magick::LagrangeFilter) unless ro == r

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
