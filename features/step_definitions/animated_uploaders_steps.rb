Допустим('єствує прѣдвижьба {string} сꙛ повторенјем {string} раза') do |format, iterations|
   @animation_iterations = iterations.to_i
   gif = File.join(@workdir, 'animation.gif')
   MiniMagick::Tool::Convert.new do |convert|
      convert.delay 12
      convert.size '480x400'
      convert.xc 'red'
      convert.delay 34
      convert.xc 'blue'
      convert.delay 56
      convert.xc 'green'
      convert.loop @animation_iterations
      convert << gif
   end
   animation_source(format, gif)
   if format == 'WEBP'
      expect(animation_webp_metadata(@image_source)).to eq(frames: 3, loop: @animation_iterations, delays: @animation_delays)
   end
end

То('кадри, паузе и повторенје извода сѫ сохранеными') do
   expect_animation_metadata(@processed_image)
end

То('кадри, паузе и повторенје мелкашке сѫ сохранеными') do
   expect_animation_metadata(@thumbnail_image) if @thumbnail_image
end

Допустим('єствує прозрачна прѣдвижьба {string} сꙛ отстѫпами кадров') do |format|
   gif = File.join(@workdir, 'animation.gif')
   MiniMagick::Tool::Convert.new do |convert|
      convert.dispose 'Background'
      convert.delay 12
      convert.size '80x40'
      convert.xc 'none'
      convert.fill 'red'
      convert.draw 'rectangle 0,0 19,19'
      convert << '('
      convert.delay 34
      convert.size '80x40'
      convert.xc 'none'
      convert.fill 'blue'
      convert.draw 'rectangle 60,20 79,39'
      convert << ')'
      convert << '('
      convert.delay 56
      convert.size '80x40'
      convert.xc 'none'
      convert.fill 'green'
      convert.draw 'rectangle 30,10 49,29'
      convert << ')'
      convert.loop 3
      convert.layers 'Optimize'
      convert << gif
   end
   animation_source(format, gif)
   @original_animation_pixels = rendered_animation(@image_source)
end

То('прозрачны кадри извода сѫ сохранеными') do
   expect(animation_webp_metadata(@processed_image)).to eq(frames: 3, loop: 3, delays: @animation_delays)
   expect(rendered_animation(@processed_image)).to eq(@original_animation_pixels)
end

Если('творьба анимације є прерваној ошибкој webpmux') do
   uploader = ImageUploader.new(Struct.new(:uid).new('animation-error'))
   uploader.root = @workdir
   status = stub(success?: false)
   Open3.stubs(:capture3).returns(['', 'webpmux failed', status])
   @image_processing = -> { File.open(@image_source) { |file| uploader.cache!(file) } }
end

То('врѣменне слике анимације сѫ изјѧтыми') do
   expect(Dir[File.join(Dir.tmpdir, 'carrierwave-animation*')] - @animation_directories_before).to be_empty
end
