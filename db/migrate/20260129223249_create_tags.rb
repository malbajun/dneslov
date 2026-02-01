class CreateTags < ActiveRecord::Migration[7.0]
   enable_extension "btree_gin"

   def change
      create_table :tags do |t|
         t.string :kind, index: true, default: "обычна", null: false, comment: "взор мѣте: обычна, помѣстна"
         t.integer :tagged_count, default: 0, null: false, comment: "счєтник помѣченых"

         t.timestamps
      end

      create_table :taggables do |t|
         t.references :taggable, polymorphic: true, index: true, null: false, comment: "квѧзка до помѣченых"
         t.references :tag, index: true, null: false, comment: "квѧзка до мѣте"

         t.index %i(taggable_id taggable_type tag_id), unique: true
      end

      change_table :descriptions do |t|
         t.tsvector :tsv
         t.index :tsv, using: :gin
      end

      reversible do |dir|
         dir.down do
            [
          "DELETE FROM descriptions
                 WHERE descriptions.describable_type = 'Tag'",
            ].each {|q| ActiveRecord::Base.connection.execute(q) }
         end
      end

   end
end
