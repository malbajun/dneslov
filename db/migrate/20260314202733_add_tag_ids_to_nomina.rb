class AddTagIdsToNomina < ActiveRecord::Migration[7.0]
   def change
      change_table :nomina do |t|
         t.bigint:tag_ids, index: true, default: [], array: true, comment: "квѧзък набор до мѣте"
      end

      drop_table :taggables do |t|
         t.references :taggable, polymorphic: true, index: true, null: false, comment: "квѧзка до помѣченых"
         t.references :tag, index: true, null: false, comment: "квѧзка до мѣте"

         t.index %i(taggable_id taggable_type tag_id), unique: true
      end
   end
end
