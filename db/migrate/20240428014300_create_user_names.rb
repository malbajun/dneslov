class CreateUserNames < ActiveRecord::Migration[7.0]
   def change
      create_table :user_names do |t|
         t.string :kind, null: false, index: true
         t.string :way, null: false, index: true
         t.string :usage, null: false, index: true
         t.string :source, null: false, index: true
         t.boolean :main, null: false, default: false, index: true
         t.references :bindable, polymorphic: true, index: true, optional: true
         t.references :user, index: true, null: false, foreign_key: { on_delete: :cascade }
         t.references :nomen, index: true, null: false, foreign_key: { on_delete: :cascade }
      end
   end
end
