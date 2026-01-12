class AddEventToMemoScripta < ActiveRecord::Migration[7.0]
   def change
      change_table :memo_scripta do |t|
         t.references :event, index: true, comment: "квѧзка до сꙛбытја"
      end

      reversible do |dir|
         dir.up do
            [
               "UPDATE memo_scripta
                   SET event_id = memoes.event_id
                  FROM memoes
                 WHERE memoes.id = memo_scripta.memo_id",
          "DELETE FROM memo_scripta
                 WHERE memo_scripta.event_id IS NULL",
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end
   end
end
