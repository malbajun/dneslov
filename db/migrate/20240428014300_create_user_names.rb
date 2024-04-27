class CreateUserNames < ActiveRecord::Migration[7.0]
   def change
      create_table :user_names do |t|
         t.string :kind, null: false, index: { unique: true }
         t.references :user, index: true, null: false, foreign_key: { on_delete: :restrict }
         t.references :nomen, index: true, null: false, foreign_key: { on_delete: :restrict }
      end
   end
end
