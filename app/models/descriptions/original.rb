class Original < Description
   extend ValidationCancel

   cancel_validates :text, :language_code, :alphabeth_code

   after_save :rewrite_la

   def fill_in_la
      if self.describable
         self.language_code ||= self.describable.calendary.language_code
         self.alphabeth_code ||= self.describable.calendary.alphabeth_code
      end
   end

   def rewrite_la
      sql = "UPDATE descriptions
                SET language_code = '#{self.describable.calendary.language_code}',
                    alphabeth_code = '#{self.describable.calendary.alphabeth_code}'
              WHERE id = #{self.id}"
      arel = Arel.sql(sanitize_for_mass_assignment(sql))
      self.class.connection.execute(arel)
   end
end
