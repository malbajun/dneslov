# изнахоѕь яко картинка
class Resource::Pictura < Resource
   mount_base64_uploader :resource, PicturaUploader
   process_in_background :resource
   store_in_background :resource

   scope :image, ->() do
      json_re = '$.** ? (@ like_regex "(roundel|icon|both)")'
      where("jsonb_path_exists(resources.props, '#{json_re}')")
   end
end
