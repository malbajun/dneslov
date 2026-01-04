class CreateResourceMarkups < ActiveRecord::Migration[7.0]
   def change
      create_table :resource_markups do |t|
         t.references :resource, foreign_key: { on_delete: :restrict }, comment: "квѧзка до изнахоѕи"
         t.references :scriptum, foreign_key: { on_delete: :cascade }, comment: "квѧзка до писаня"
         t.string :address, comment: "розполага на изнахоѕи"
         t.box :placement, comment: "розмѣщенје на изнахоэи"

         t.timestamps

         t.index %i(resource_id scriptum_id), unique: true
      end
   end
end
