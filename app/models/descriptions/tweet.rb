class Tweet < Description
   validate :all_downcase, if: :present?

   def all_downcase
      if text != text.downcase
         errors.add(:text, "has invalid characters '#{(text.unpack("U*") - text.downcase.unpack("U*")).pack("U*")}'")
      end
   end
end
