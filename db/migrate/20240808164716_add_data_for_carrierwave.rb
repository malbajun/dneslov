class AddDataForCarrierwave < ActiveRecord::Migration[7.0]
   def change
      safety_assured do
         add_column :pictures, :image_processing, :boolean, null: false, default: false
         add_column :pictures, :image_tmp, :string

         add_column :roundels, :image_processing, :boolean, null: false, default: false
         add_column :roundels, :image_tmp, :string
      end
   end
end
