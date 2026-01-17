class Note < Description
   validates :text, :language_code, :alphabeth_code, presence: true
   validates_length_of :text, in: 5..980, allow_blank: false
end
