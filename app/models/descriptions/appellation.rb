class Appellation < Description
   validates :text, :language_code, :alphabeth_code, presence: true
end
