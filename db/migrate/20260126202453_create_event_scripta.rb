class CreateEventScripta < ActiveRecord::Migration[7.0]
   def change
      create_table :event_scripta do |t|
         t.references :event, foreign_key: { on_delete: :cascade }, comment: "квѧзка до сꙛбытя"
         t.references :scriptum, foreign_key: { on_delete: :cascade }, comment: "квѧзка до буке"
         t.string :kind, comment: "Тип свѧзке от, к, или авторство"

         t.index %i(event_id scriptum_id), unique: true, name: "event_scripta_on_event_id_and_scriptum_id"
      end

      reversible do |dir|
         dir.up do
            [
               "INSERT INTO event_scripta (event_id, scriptum_id, kind)
                SELECT memo_scripta.event_id, memo_scripta.scriptum_id, memo_scripta.kind
                  FROM memo_scripta
           ON CONFLICT (event_id, scriptum_id)
            DO NOTHING"
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end
   end
end
