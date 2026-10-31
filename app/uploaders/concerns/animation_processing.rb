require 'open3'
require 'tmpdir'

module AnimationProcessing
   def convert format, page = nil, &block
      return super unless format.to_s == 'webp' && page.nil? && animated_image?

      process_animation { |image| block.call(image) if block }
   end

   def auto_orient
      if animated_image?
         process_animation { |image| image.auto_orient }
      else
         manipulate! do |image|
            image.auto_orient
            image
         end
      end
   end

   def thumbnail width, height
      return super unless animated_image?

      process_animation { |image| framed_thumbnail(image, width, height) }
   end

   def resize_to_fit width, height, &block
      return super unless animated_image?

      process_animation do |image|
         image.resize "#{width}x#{height}"
         block.call(image) if block
      end
   end

   private

   def animated_image?
      image = ::MiniMagick::Image.new(current_path)
      %w(GIF WEBP).include?(image.type) && image.frames.length > 1
   rescue ::MiniMagick::Error, ::MiniMagick::Invalid => error
      raise CarrierWave::ProcessingError, error.message
   end

   def process_animation
      source = ::MiniMagick::Image.new(current_path)
      if source.type == 'WEBP'
         # ImageMagick can round WebP delays to centiseconds. Read exact ms.
         info = webpmux('-info', current_path)
         iterations = info[/Loop Count\s*:\s*(\d+)/, 1]
         delays = info.lines.filter_map do |line|
            fields = line.split
            fields[6].to_i if fields.first&.match?(/^\d+:$/)
         end
         raise CarrierWave::ProcessingError, 'Invalid WebP animation metadata' unless iterations && delays.any?
      else
         metadata = source.frames.map(&:data)
         delays = metadata.map do |frame|
            delay, ticks = frame.fetch('delay', '0x100').split('x').map(&:to_i)
            (1000.0 * delay / ticks).round
         end
         iterations = metadata.first.fetch('iterations', 1)
      end

      Dir.mktmpdir('carrierwave-animation') do |directory|
         # Render disposal and partial-frame offsets before resizing/compositing.
         ::MiniMagick::Tool::Convert.new do |convert|
            convert << current_path
            convert.coalesce
            convert << '+adjoin'
            convert << File.join(directory, 'frame-%06d.png')
         end

         frames = Dir[File.join(directory, 'frame-*.png')].sort
         unless frames.length == delays.length
            raise CarrierWave::ProcessingError, 'Animation frame count changed during decoding'
         end

         arguments = []
         frames.each_with_index do |path, index|
            image = ::MiniMagick::Image.new(path)
            yield image
            webp = File.join(directory, "frame-#{index}.webp")
            ::MiniMagick::Tool::Convert.new do |convert|
               convert << image.path
               convert.define 'webp:lossless=true'
               convert << webp
            end
            # Coalesced frames are complete canvases: replace, do not blend.
            arguments.concat(['-frame', webp, "+#{delays[index]}+0+0+1-b"])
         end

         output = File.join(directory, 'animation.webp')
         webpmux(*arguments, '-loop', iterations.to_s, '-bgcolor', '0,0,0,0', '-o', output)

         FileUtils.mv(output, current_path)
         unless File.extname(current_path).downcase == '.webp'
            destination = current_path.chomp(File.extname(current_path)) + '.webp'
            file.content_type = 'image/webp'
            file.move_to(destination, permissions, directory_permissions)
         end
      end
   rescue ::MiniMagick::Error, ::MiniMagick::Invalid => error
      raise CarrierWave::ProcessingError, error.message
   end

   def webpmux *arguments
      output, error, status = Open3.capture3('webpmux', *arguments)
      raise CarrierWave::ProcessingError, error unless status.success?

      output
   rescue Errno::ENOENT
      raise CarrierWave::ProcessingError, 'Animation processing requires webpmux (libwebp-tools)'
   end
end
