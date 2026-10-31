module FramedThumbnail
   def thumbnail width, height
      ratio = self.width.to_f / self.height
      ratio_in = width.to_f / height
      width, height = ratio > ratio_in ? [width, ratio_in / ratio * height] : [width, ratio / ratio_in * height]
      geometry = "#{width.to_i}x#{height.to_i}"
      canvas = "#{(width + 6).to_i}x#{(height + 6).to_i}"

      manipulate! do |image|
         ::MiniMagick::Tool::Convert.new do |convert|
            convert.size canvas
            convert.xc 'gray95'
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
            convert << image.path
         end

         image
      end
   end
end
