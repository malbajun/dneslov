module TiffConversion
   def convert format, page = nil, &block
      image = ::MiniMagick::Image.new(current_path)
      if page.nil? && image.type == 'TIFF'
         # TIFF's reduced-image flag distinguishes thumbnails from real pages.
         # A smaller page without that flag is still a legitimate document page.
         page = image.pages.index do |frame|
            subfiletype = frame.data.fetch('properties', {}).fetch('tiff:subfiletype', '')
            !subfiletype.split(/[,\s]+/).include?('REDUCEDIMAGE')
         end
         raise CarrierWave::ProcessingError, 'TIFF contains only thumbnails' if page.nil?
      end

      super(format, page, &block)
   end
end
