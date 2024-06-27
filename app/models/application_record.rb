class ApplicationRecord < ActiveRecord::Base
   self.abstract_class = true

   scope :ranged_with, ->(range) do
      if range
         offset(range.begin).limit(range.end - range.begin + 1)
      else
         unscope(:limit).unscope(:offset)
      end
   end
end
