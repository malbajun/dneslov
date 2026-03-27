class CreateUniqIndexOnDescriptions < ActiveRecord::Migration[7.0]
   def change
      reversible do |dir|
         dir.up do
            [
               "UPDATE descriptions
                   SET type = 'Title'
                 WHERE type = 'Appellation'
                   AND describable_type = 'Calendary'"
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end

         dir.down do
            [
               "UPDATE descriptions
                   SET type = 'Appellation'
                 WHERE type = 'Title'
                   AND describable_type = 'Calendary'"
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end

      safety_assured do
         add_index(:descriptions, "language_code, alphabeth_code, describable_type, md5(text)",
            name: "index_descriptions_on_la_type_text",
            unique: true,
            where: "type = 'Appellation'")
      end
   end
end
