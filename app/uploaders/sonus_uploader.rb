class SonusUploader < CarrierWave::Uploader::Base
   include ::CarrierWave::Backgrounder::Delay
   include ::CarrierWave::FFmpeg

   cache_storage CarrierWave::Storage::File
   storage :file

   process :digest
   process convert: "opus"

   def digest
      digest = Digest::SHA2.hexdigest(IO.read(current_path))
      file.instance_variable_set(:@digest, digest)
   end

   def store_dir
      "soni/#{model.uid[0..1]}"
   end

   def filename
      "#{model.uid}.#{file.extension}"
   end

   def content_type_allowlist
      [/audio\//]
   end
end
