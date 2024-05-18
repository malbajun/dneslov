class CreateMembers < ActiveRecord::Migration[7.0]
   def change
      create_table :members do |t|
         t.references :user, index: true, null: false, foreign_key: { on_delete: :cascade }
         t.references :role, index: true, null: false, foreign_key: { on_delete: :cascade }

         t.timestamps
      end
   end
end
