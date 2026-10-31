Допустим('єствує картинка размѣра {string}') do |geometry|
   @image_source = File.join(@workdir, 'source.png')
   MiniMagick::Tool::Convert.new do |convert|
      convert.size geometry
      convert.xc 'red'
      convert << @image_source
   end
end

Допустим('єствує прозрачна картинка размѣра {string}') do |geometry|
   @image_source = File.join(@workdir, 'source.png')
   MiniMagick::Tool::Convert.new do |convert|
      convert.size geometry
      convert.xc 'none'
      convert.fill 'red'
      convert.draw 'rectangle 50,50 150,150'
      convert << @image_source
   end
end

Допустим('єствує картинка со самоповратностјѫ {string}') do |orientation|
   @image_source = File.join(@workdir, 'source.tiff')
   MiniMagick::Tool::Convert.new do |convert|
      convert.size '80x40'
      convert.xc 'red'
      convert.orient orientation
      convert << @image_source
   end
   expect(MiniMagick::Image.new(@image_source)['%[orientation]']).to eq(orientation)
end

Если('картинка є загрѫженој чрѣз {string}') do |class_name|
   # Cache real uploads, with all processing enabled, inside the scenario directory.
   uploader_class = Class.new(class_name.constantize) do
      define_method(:cache_dir) { File.join(root, 'cache') }
   end
   @image_uploader = uploader_class.new(Struct.new(:uid).new('test-image'))
   @image_uploader.root = @workdir
   @image_uploader.versions.each_value { |version| version.root = @workdir }
   @image_uploader.enable_processing = true
   @mini_magick_files_before = Dir[File.join(Dir.tmpdir, 'mini_magick*')]
   File.open(@image_source) { |file| @image_uploader.cache!(file) }
   @processed_image = @image_uploader.path
   @thumbnail_image = @image_uploader.thumb.path if @image_uploader.respond_to?(:thumb)
   expect(@processed_image).to start_with(@workdir + File::SEPARATOR)
   expect(@thumbnail_image).to start_with(@workdir + File::SEPARATOR) if @thumbnail_image
end

Если('BookUploader твори мелкашькѫ картинке') do
   # Exercise the book thumbnail processor independently of PDF/DjVu delegates.
   uploader = BookUploader.new
   uploader.stubs(:cached?).returns(true)
   uploader.stubs(:current_path).returns(@image_source)
   @mini_magick_files_before = Dir[File.join(Dir.tmpdir, 'mini_magick*')]
   uploader.thumbnail(400, 400)
   @thumbnail_image = @image_source
end

То('извод картинке є {string} размѣра {string}') do |format, geometry|
   image = MiniMagick::Image.new(@processed_image)
   expect(image.type).to eq(format)
   expect(image.dimensions.join('x')).to eq(geometry)
end

То('мелкашка є {string} размѣра {string}') do |format, geometry|
   image = MiniMagick::Image.new(@thumbnail_image)
   expect(image.type).to eq(format)
   expect(image.dimensions.join('x')).to eq(geometry)
end

То('мелкашка имає сѣрѫ обчьрненѫ рамкѫ') do
   image = MiniMagick::Image.new(@thumbnail_image)
   pixels = image.get_pixels
   middle = pixels[image.height / 2]
   # The bevel has a light edge, a dark edge and a red image in the centre.
   left, right, centre = middle[0], middle[-1], middle[image.width / 2]
   expect(left.max - left.min).to be <= 30
   expect(right.max - right.min).to be <= 30
   expect(left.take(3).sum).to be > right.take(3).sum
   expect(centre[0]).to be > centre[1] + 100
   expect(centre[0]).to be > centre[2] + 100
end

То('прозрачность картинке є сохраненој') do
   image = MiniMagick::Image.new(@processed_image)
   expect(image['%[opaque]']).to eq('false')
   expect(image.get_pixels.first.first.last).to eq(0)
end

Если('творьба мелкашьк є прерваној ошибкој MiniMagick') do
   uploader = ImageUploader.new
   uploader.stubs(:cached?).returns(true)
   uploader.stubs(:current_path).returns(@image_source)
   @mini_magick_files_before = Dir[File.join(Dir.tmpdir, 'mini_magick*')]
   MiniMagick::Tool::Convert.stubs(:new).raises(MiniMagick::Error, 'conversion failed')
   @image_processing = -> { uploader.thumbnail(400, 400) }
end

То('ошибка обработке є повращеној') do
   expect(&@image_processing).to raise_error(CarrierWave::ProcessingError)
end

То('врѣменне слике MiniMagick сѫ изјѧтыми') do
   expect(Dir[File.join(Dir.tmpdir, 'mini_magick*')] - @mini_magick_files_before).to be_empty
end

Допустим('єствує порчена картинка') do
   @image_source = File.join(@workdir, 'broken.png')
   File.binwrite(@image_source, "not an image")
end

Если('загрѫзчик твори мелкашькѫ порчене картинке') do
   uploader = ImageUploader.new
   uploader.stubs(:cached?).returns(true)
   uploader.stubs(:current_path).returns(@image_source)
   @mini_magick_files_before = Dir[File.join(Dir.tmpdir, 'mini_magick*')]
   @image_processing = -> { uploader.thumbnail(400, 400) }
end
