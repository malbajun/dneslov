class Title < Description
   has_alphabeth on: { text: [ :nospecific ] }

   validates :text, :language_code, :alphabeth_code, presence: true
end
