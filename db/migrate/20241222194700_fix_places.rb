class FixPlaces < ActiveRecord::Migration[7.0]
   def change
      change_table :coverings do |t|
         t.remove_foreign_key(column: :place_id)
      end

      safety_assured do
         reversible do |dir|
            dir.up do
               [
             "UPDATE events
                 SET place_id = events.place_id + 20000",
             "UPDATE calendaries
                 SET place_id = calendaries.place_id + 20000",
             "UPDATE coverings
                 SET place_id = coverings.place_id + 20000",
              ].each { |q| Order.connection.execute(q) }
            end
         end
      end

      add_foreign_key :coverings, :memories, column: :place_id, primary_key: "id", on_delete: :cascade
      add_foreign_key :calendaries, :memories, column: :place_id, primary_key: "id", on_delete: :cascade
      add_foreign_key :events, :memories, column: :place_id, primary_key: "id", on_delete: :cascade
   end
end
