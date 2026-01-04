# изнахоѕь яко книга в обраме pdf, djvu або инѣх
class Resource::Book < Resource
   mount_base64_uploader :resource, BookUploader
   process_in_background :resource
   store_in_background :resource

   before_validation :fill_in_thumb_url

   def fill_in_thumb_url
      if changed.include?("resource")
         self.thumb_url = File.join *[resource.asset_host.to_s, resource.store_dir, resource.thumb.filename]
      end
   end
end
