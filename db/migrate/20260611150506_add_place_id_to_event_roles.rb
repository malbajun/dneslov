class AddPlaceIdToEventRoles < ActiveRecord::Migration[7.0]
   def change
      change_table :event_roles do |t|
         t.references :place, foreign_key: { on_delete: :restrict }, comment: "Ссылка на место"
      end
   end
end
