class ChangeBondEventInMemoryBinds < ActiveRecord::Migration[7.0]
   def change
      reversible do |dir|
         dir.up do
            [
              " UPDATE memory_binds
                   SET bond_event_id = events.id
                  FROM events
                 WHERE memory_binds.bond_to_id = events.memory_id
                   AND memory_binds.bond_to_id IN (
                SELECT memory_id
                  FROM events
                 ORDER BY
                  CASE events.kind_code
                  WHEN 'Veneration' THEN 1
                  WHEN 'Repose' THEN 2
                  WHEN 'Passion' THEN 3
                  WHEN 'Glorification' THEN 4
                  ELSE 5
                  END, memory_id)"
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end

      remove_column :memory_binds, :bond_to_id, type: :references, comment: "памѧть яко цєлєва квѧзка"
   end
end
