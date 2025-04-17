class CreateRites < ActiveRecord::Migration[7.0]
   def change
      create_table :rites do |t|
         t.string :abbreviation, index: { unique: true }
         t.text :text, index: true
         t.string :language_code, index: true
         t.string :alphabeth_code, index: true
         t.string :bind_kind_rite, null: false
         t.string :bind_kind_path
         t.references :bond_to, index: true, foreign_key: { to_table: :rites, on_delete: :restrict }
         t.references :root, index: true, foreign_key: { to_table: :rites, on_delete: :restrict }

         t.timestamps
      end

      reversible do |dir|
         dir.up do
            [
            "
            CREATE OR REPLACE FUNCTION fill_in_root_id() RETURNS trigger AS $$
                declare
                   root_id BIGINT;
                begin
                   SELECT DISTINCT rites.root_id INTO root_id FROM rites WHERE new.bond_to_id = rites.id OR new.root_id = rites.id;

                   new.root_id := COALESCE(root_id, new.id);
                   return new;
                end
                $$ LANGUAGE plpgsql",
            "CREATE TRIGGER check_update
           BEFORE INSERT ON rites
               FOR EACH ROW
           EXECUTE FUNCTION fill_in_root_id()"
            ].each { |sql| ActiveRecord::Base.connection.execute(sql) }
         end
      end
   end
end
