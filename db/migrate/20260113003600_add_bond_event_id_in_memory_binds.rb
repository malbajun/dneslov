class AddBondEventIdInMemoryBinds < ActiveRecord::Migration[7.0]
   def change
      change_table :memory_binds do |t|
         t.references :bond_event, foreign_key: { to_table: :events, on_delete: :restrict }, comment: "сꙛбытие яко цєлєва квѧзка"
      end
   end
end
