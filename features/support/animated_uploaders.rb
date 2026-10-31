module AnimatedUploaderSteps
   def animation_webp_metadata(path)
      output, error, status = Open3.capture3('webpmux', '-info', path)
      expect(status.success?).to be(true), error
      {
         frames: output[/Number of frames: (\d+)/, 1].to_i,
         loop: output[/Loop Count\s*:\s*(\d+)/, 1].to_i,
         delays: output.lines.filter_map do |line|
            fields = line.split
            fields[6].to_i if fields.first&.match?(/^\d+:$/)
         end
      }
   end

   def animation_source(format, gif)
      @image_source = gif
      @animation_delays = [120, 340, 560]
      if format == 'WEBP'
         @image_source = File.join(@workdir, 'animation.webp')
         _, error, status = Open3.capture3('gif2webp', '-quiet', gif, '-o', @image_source)
         expect(status.success?).to be(true), error
         # Non-centisecond timings must survive every WebP processing step.
         @animation_delays = [121, 347, 569]
         arguments = @animation_delays.each_with_index.flat_map { |delay, i| ['-duration', "#{delay},#{i + 1}"] }
         retimed = File.join(@workdir, 'retimed.webp')
         _, error, status = Open3.capture3('webpmux', *arguments, @image_source, '-o', retimed)
         expect(status.success?).to be(true), error
         FileUtils.mv(retimed, @image_source)
      end
      @animation_directories_before = Dir[File.join(Dir.tmpdir, 'carrierwave-animation*')]
   end

   def expect_animation_metadata(path)
      expect(animation_webp_metadata(path)).to eq(frames: 3, loop: @animation_iterations, delays: @animation_delays)
      image = MiniMagick::Image.new(path)
      image.frames.each_with_index do |frame, index|
         x, y = frame.width / 2, frame.height / 2
         colour = frame["%[pixel:p{#{x},#{y}}]"].scan(/\d+/).map(&:to_i)
         channel = [0, 2, 1][index] # red, blue, green
         expect(colour[channel]).to be > 100
         expect(colour.values_at(*([0, 1, 2] - [channel])).max).to be < 10
      end
   end

   def rendered_animation(path)
      bytes = MiniMagick::Tool::Convert.new do |convert|
         convert << path
         convert.coalesce
         convert.depth 8
         convert << 'rgba:-'
      end
      # Invisible RGB values need not survive re-encoding; alpha must survive.
      bytes.bytes.each_slice(4).map { |pixel| pixel.last.zero? ? [0, 0, 0, 0] : pixel }
   end
end

World(AnimatedUploaderSteps)
