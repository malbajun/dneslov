class CreateRoles < ActiveRecord::Migration[7.0]
   def change
      create_table :roles do |t|
         t.string :permissions, array: true, index: { using: 'gin' }, default: []
         t.boolean :default, index: { unique: true }

         t.timestamps
      end
   end
end
