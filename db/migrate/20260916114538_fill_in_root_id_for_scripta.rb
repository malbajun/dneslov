class FillInRootIdForScripta < ActiveRecord::Migration[7.0]
   def change
      reversible do |dir|
         dir.up do
            [
            "
            CREATE OR REPLACE FUNCTION fill_in_root_id_for_scripta() RETURNS trigger AS $$
                declare
                   root_id BIGINT;
                begin
                   SELECT DISTINCT scripta.root_id INTO root_id FROM scripta WHERE new.bond_to_id = scripta.id OR new.root_id = scripta.id;

                   new.root_id := COALESCE(root_id, new.id);
                   return new;
                end
                $$ LANGUAGE plpgsql",
            "CREATE TRIGGER scripta_check_update
           BEFORE INSERT ON scripta
               FOR EACH ROW
           EXECUTE FUNCTION fill_in_root_id_for_scripta()"
            ].each { |sql| ActiveRecord::Base.connection.execute(sql) }
         end

         dir.down do
            [
            "DROP FUNCTION IF EXISTS fill_in_root_id_for_scripta CASCADE"
            ].each { |sql| ActiveRecord::Base.connection.execute(sql) }
         end
      end
   end
end
