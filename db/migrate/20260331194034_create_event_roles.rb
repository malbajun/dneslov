class CreateEventRoles < ActiveRecord::Migration[7.0]
   def change
      create_table :event_roles do |t|
         t.references :event, index: true, foreign_key: { on_delete: :cascade }
         t.references :memory, index: true, foreign_key: { on_delete: :cascade }
         t.string :type, index: true
         t.string :agonism, index: true
         t.string :event_kind_code, index: true

         t.timestamps

         t.index %i(event_id memory_id), unique: true
      end

      change_table :memoes do |t|
         t.references :event_role, index: true, foreign_key: { on_delete: :restrict }
      end

      change_column_null :events, :memory_id, true

      reversible do |dir|
         dir.up do
            [
              "INSERT INTO event_roles (event_id, memory_id, event_kind_code, created_at, updated_at)
                    SELECT events.id, events.memory_id, events.kind_code, now(), now()
                      FROM events",
                     "WITH _role_descs AS (
                    SELECT event_descriptions.type,
                           event_descriptions.text,
                           event_descriptions.alphabeth_code,
                           event_descriptions.language_code,
                           event_roles.id AS id
                      FROM descriptions AS event_descriptions
                      JOIN event_roles
                        ON event_roles.event_id = event_descriptions.describable_id
                       AND 'Event' = event_descriptions.describable_type)
              INSERT INTO descriptions
                          (describable_id, describable_type, type, text, alphabeth_code, language_code, created_at, updated_at)
                    SELECT _role_descs.id,
                           'EventRole',
                           _role_descs.type,
                           _role_descs.text,
                           _role_descs.alphabeth_code,
                           _role_descs.language_code,
                           now(),
                           now()
                      FROM _role_descs",
                     "WITH _memo_roles AS (
                    SELECT event_roles.id AS event_role_id,
                           memoes.id AS memo_id
                      FROM memoes
                      JOIN event_roles
                        ON event_roles.event_id = memoes.event_id)
                    UPDATE memoes
                       SET event_role_id = _memo_roles.event_role_id
                      FROM _memo_roles
                     WHERE _memo_roles.memo_id = memoes.id",
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end

         dir.down do
            [
              "DELETE FROM descriptions
                     WHERE describable_type = 'EventRole'",
                   "UPDATE memoes
                       SET event_id = event_roles.event_id
                      FROM event_roles
                     WHERE memoes.event_role_id = event_roles.id",
                   "UPDATE events
                       SET memory_id = event_roles.memory_id
                      FROM event_roles
                     WHERE event_roles.event_id = events.id",
             ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end

      remove_column :memoes, :event_id, :bigint
      remove_column :events, :memory_id, :bigint
   end
end
