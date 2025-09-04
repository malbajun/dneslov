# изнахоѕь яко книга в обраме pdf, djvu або инѣх
class Resource::Book < Resource
   mount_base64_uploader :resource, BookUploader
   process_in_background :resource
   store_in_background :resource
end
