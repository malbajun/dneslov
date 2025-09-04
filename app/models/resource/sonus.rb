# изнахоѕь яко гуѕба ако нѣкаков звѫк
class Resource::Sonus < Resource
   mount_base64_uploader :resource, SonusUploader
   process_in_background :resource
   store_in_background :resource
end
