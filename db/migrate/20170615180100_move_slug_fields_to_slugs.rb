class MoveSlugFieldsToSlugs < ActiveRecord::Migration[5.2]
   def change
      create_table :slugs, id: :serial do |t|
         t.string :text, null: false, index: true
         t.belongs_to :sluggable, polymorphic: true, index: true
      end

      remove_column :memories, :short
      remove_column :calendaries, :slug
   end
end
