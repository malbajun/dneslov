class Tweet < Description
   has_alphabeth on: { text: [ :nospecific ] }

   validates :text, :language_code, :alphabeth_code, presence: true
   validate :all_downcase, if: :present?

   def all_downcase
      if text != text.downcase
         errors.add(:text, "has invalid characters '#{(text.unpack("U*") - text.downcase.unpack("U*")).pack("U*")}'")
      end
   end
end
