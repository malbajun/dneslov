class RenameThumbs < ActiveRecord::Migration[7.0]
   def change
      rename_column :thumbs, :thumb, :image
      rename_column :thumbs, :thumbable_id, :roundelable_id
      rename_column :thumbs, :thumbable_type, :roundelable_type
      rename_table :thumbs, :roundels
   end
end
