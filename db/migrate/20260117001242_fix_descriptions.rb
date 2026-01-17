class FixDescriptions < ActiveRecord::Migration[7.0]
   def change
      change_column_null :descriptions, :language_code, true
      change_column_null :descriptions, :alphabeth_code, true

      reversible do |dir|
         dir.up do
            [
              " UPDATE descriptions
                   SET type = 'Tale'
                 WHERE type = 'Description'"
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end
   end
end
