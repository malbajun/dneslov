module FramedThumbnail
   def thumbnail width, height
      # Validate before opening a temporary copy: MiniMagick 4 leaves that copy
      # behind if validation fails inside Image.open.
      ::MiniMagick::Image.new(current_path).validate!

      manipulate! do |image|
         ratio = image.width.to_f / image.height
         ratio_in = width.to_f / height
         width, height = ratio > ratio_in ? [width, ratio_in / ratio * height] : [ratio / ratio_in * width, height]
         geometry = "#{width.to_i}x#{height.to_i}"
         canvas = "#{(width + 6).to_i}x#{(height + 6).to_i}"

         ::MiniMagick::Tool::Convert.new do |convert|
            convert.size canvas
            convert.xc 'gray95'
            convert.colorspace 'sRGB'
            convert.type 'TrueColor'
            convert << '('
            convert.size canvas
            convert.xc 'gray75'
            convert.raise '3x3'
            convert << ')'
            convert.gravity 'Center'
            convert.compose 'Over'
            convert.composite
            convert << '('
            convert << image.path
            convert.thumbnail geometry
            convert << ')'
            convert.composite
            convert.type 'TrueColor'
            convert << image.path
         end

         image
      end
   rescue ::MiniMagick::Invalid
      raise CarrierWave::ProcessingError, I18n.translate(:"errors.messages.processing_error")
   end
end
