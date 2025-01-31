# https://stackoverflow.com/questions/64668994/when-using-postgres-enum-types-with-rails-specifying-create-type-xyz-setting-as
class CreateScriptumScribables < ActiveRecord::Migration[7.0]
   def change
      create_enum :scribable_kind, %w(source target)

      create_table :scriptum_scribables do |t|
         t.references :scribable, null: false, polymorphic: true, index: true, comment: "Квѧзка до описуема прѣдмѣта"
         t.references :scriptum, null: false, index: true, comment: "Квѧзка до бука"

         t.enum :kind, enum_type: :scribable_kind, null: false, index: true, comment: "Взор квѧзке извор або цѣль"
      end
   end
end
