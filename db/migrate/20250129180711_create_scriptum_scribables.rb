class CreateScriptumScribables < ActiveRecord::Migration[7.0]
   def change
      create_table :scriptum_scribables do |t|
         t.references :scribable, polymorphic: true, index: true, comment: "Квѧзка до описуема прѣдмѣта"
         t.references :scriptum, index: true, comment: "Квѧзка до бука"
      end
   end
end
