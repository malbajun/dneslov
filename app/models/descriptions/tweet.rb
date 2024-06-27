class Tweet < Description
   validate :all_downcase, if: :present?

   def all_downcase
      if text != text.downcase && text != "Бог" #TODO
         errors.add(:text, "has invalid characters '#{text - text.downcase}'")
      end
   end
end
