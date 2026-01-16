class Original < Description
   extend ValidationCancel

   cancel_validates :text

   def fill_in_la
     binding.pry
      self.language_code ||= self.describable.calendary.language_code
      self.alphabeth_code ||= self.describable.calendary.alphabeth_code
   end
end
