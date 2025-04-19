class ShortName < ApplicationRecord
   include Languageble

   belongs_to :memory

   has_alphabeth on: :text, novalidate: true

   validates :text, :language_code, :alphabeth_code, presence: true

   before_validation :fill_in_la

   def fill_in_la
      if text && !(self.language_code && self.alphabeth_code)
         self.language_code, self.alphabeth_code = Languageble.la_for_string(text)
      end
   end
end
