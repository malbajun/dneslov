class MergeNominaAndNames < ActiveRecord::Migration[7.0]
   # urreversible
   def change
      reversible do |dir|
         dir.up do
            change_table :nomina do |t|
               t.text :text, index: { using: :gin }
               t.string :language_code, index: true, limit: 6
               t.string :alphabeth_code, index: true, limit: 6
               t.string :rules, index: true, default: [], array: true
               t.string :kind, comment: "взор правила претвъра"

               t.index %i(text language_code alphabeth_code kind bond_to_id), name: "index_nomina_text_la_kind_bond_to_id", unique: true
            end
            # имя
            # - родствєнно ima1 // root
            # - родствєнно ima2 // root
            # - из имя3, правило/титул првила, ссылка на источник/титул ссылки
            #parent_id // rule // link //

            remove_index :nomina, name: :index_nomina_on_bond_to_id_and_name_id
            change_column_null :nomina, :name_id, true
            change_column_comment :nomina, :root_id, "квѧзка на корнєво имѧ, образує скупину смысла"
            change_column_comment :nomina, :bond_to_id, "квѧзка на свѧзно имѧ"
            change_column_comment :nomina, :modifier, "дане претвъра"
            change_column_comment :nomina, :name_id, "устарѣ"

            [
              "   WITH _nomina AS (
                SELECT nomina.id AS id,
                       names.language_code AS language_code,
                       names.alphabeth_code AS alphabeth_code,
                       names.text AS text,
                       bond_to_nomina.id AS bond_to_id,
                       root_nomina.id AS root_id
                  FROM nomina
       LEFT OUTER JOIN names
                    ON nomina.name_id = names.id
       LEFT OUTER JOIN nomina AS root_nomina
                    ON nomina.root_id = root_nomina.name_id
       LEFT OUTER JOIN nomina AS bond_to_nomina
                    ON nomina.bond_to_id = bond_to_nomina.name_id)
                UPDATE nomina
                   SET language_code = _nomina.language_code,
                       alphabeth_code = _nomina.alphabeth_code,
                       text = _nomina.text,
                       bond_to_id = _nomina.bond_to_id,
                       root_id = _nomina.root_id
                  FROM _nomina
                 WHERE _nomina.id = nomina.id",
              "   WITH nomen_names AS (
                SELECT names.id AS name_id,
                       nomina.id AS nomen_id
                  FROM names
                  JOIN nomina
                    ON nomina.name_id = names.id)
                UPDATE descriptions
                   SET describable_type = 'Nomen',
                       describable_id = nomen_names.nomen_id
                  FROM nomen_names
                 WHERE descriptions.describable_type = 'Name'
                   AND descriptions.describable_id = nomen_names.name_id",
              "   WITH nomen_names AS (
                SELECT names.id AS name_id,
                       nomina.id AS nomen_id
                  FROM names
                  JOIN nomina
                    ON nomina.name_id = names.id)
                UPDATE links
                   SET info_type = 'Nomen',
                       info_id = nomen_names.nomen_id
                  FROM nomen_names
                 WHERE links.info_type = 'Name'
                   AND links.info_id = nomen_names.name_id",
            ].each {|q| ActiveRecord::Base.connection.execute(q) }

            drop_table :names
         end
      end
   end
end
