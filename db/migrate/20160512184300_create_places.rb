class CreatePlaces < ActiveRecord::Migration[5.2]
   def change
      create_table :places, id: :serial do |t|
         t.timestamps null: false
      end
   end
end
