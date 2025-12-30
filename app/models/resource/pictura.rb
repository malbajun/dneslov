# изнахоѕь яко картинка
class Resource::Pictura < Resource
   mount_base64_uploader :resource, PicturaUploader
   process_in_background :resource
   store_in_background :resource

   scope :image, ->() do
      json_re = '$.** ? (@ like_regex "(roundel|icon|both)")'
      where("jsonb_path_exists(resources.props, '#{json_re}')")
   end

   before_validation :fill_in_thumb_url

   def fill_in_thumb_url
      if changed.include?("resource")
         self.thumb_url = File.join *[resource.asset_host.to_s, resource.store_dir, "thumb_" + resource.filename]
      end
   end
end
