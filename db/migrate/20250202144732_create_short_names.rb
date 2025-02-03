class CreateShortNames < ActiveRecord::Migration[7.0]
   def change
      create_table :short_names do |t|
         t.string :text, index: true, null: false
         t.string :language_code, index: true, null: false
         t.string :alphabeth_code, index: true, null: false
         t.references :memory, index: true, null: false, foreign_key: true

         t.timestamps

         t.index %i(text alphabeth_code), unique: true, name: "index_short_names_on_text_alphabeth_code"
      end

      reversible do |dir|
         dir.up do
            {
              "РО" => "ру",
              "РУ" => "ру",
              "ВС" => "вс",
              "НЦ" => "вс",
            }.each do |a, l|
               [ "INSERT INTO short_names
                              (text, language_code, alphabeth_code, created_at, updated_at, memory_id)
                       SELECT memories.short_name, '#{l}', '#{a}', now(), now(), memories.id
                         FROM memories
                        WHERE memories.short_name IS NOT NULL"
               ].each { |sql| ActiveRecord::Base.connection.execute(sql) }
            end
         end
      end

      remove_column :memories, :short_name
   end
end
