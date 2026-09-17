class RenameEventScriptaIntoHymnableScripta < ActiveRecord::Migration[7.0]
   def change
      remove_foreign_key :event_scripta, :events, on_delete: :cascade

      rename_table :event_scripta, :hymnable_scripta

      change_table :hymnable_scripta do |t|
         t.rename :event_id, :hymnable_id
         t.string :hymnable_type, index: true, default: 'EventRole'

         t.index %i(hymnable_id hymnable_type)
         t.index(%i(hymnable_id hymnable_type scriptum_id), name: "hymnable_scripta_on_hymnable_and_scriptum_id", unique: true)
         t.remove_index(%i(hymnable_id scriptum_id), name: "event_scripta_on_event_id_and_scriptum_id", unique: true)
      end

      reversible do |dir|
         dir.up do
            [
              "UPDATE hymnable_scripta
                  SET hymnable_id = event_roles.id
                 FROM event_roles
                WHERE event_roles.event_id = hymnable_scripta.hymnable_id"
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end

         dir.down do
            [
                "WITH _events AS (
               SELECT event_roles.id AS event_role_id,
                      events.id AS id
                 FROM events
                 JOIN event_roles
                   ON events.id = event_roles.event_id)
               UPDATE hymnable_scripta
                  SET hymnable_id = _events.id
                 FROM _events
                WHERE _events.event_role_id = hymnable_scripta.hymnable_id"
             ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end

      change_column_comment(:hymnable_scripta, :hymnable_id, from: "квѧзка до сꙛбытя", to: "квѧзка до памѧти або событијне роли")
      change_column_null(:hymnable_scripta, :hymnable_id, false)
      change_column_null(:hymnable_scripta, :hymnable_type, false)
   end
end
