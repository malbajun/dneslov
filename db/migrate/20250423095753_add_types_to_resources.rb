class AddTypesToResources < ActiveRecord::Migration[7.0]
   safety_assured

   PROPS = {
         text: 'text',
         pageinfo: 'text',
         bookinfo: 'text',
      }

   def change
      change_table :resources do |t|
         t.string :type, index: true, comment: "Єдьн из Book, PageSet, Pictura, Site, Sonus, Virtual, Volumen"
         t.binary :digest, index: { unique: true }, comment: "Чисмяна подпись"
         t.string :uri, index: { unique: true }, comment: "ози изнахоѕи"
         t.string :thumb_url, index: true, comment: "рзи нариснице за изнахоѕѣ"
         t.column :data, :bytea, index: true, comment: "Свѧзане дане за изнахоѕѣ"
         # internals
         t.string :resource, index: true, comment: "Поле для самє изнахоѕи"
         t.boolean :resource_processing, default: false, comment: "Обработка изнахоѕи на позадји"
         t.string :resource_tmp, comment: "Врѣмяне дане за изнахоѕѣ для позаднє обработке"
      end

      Resource.update_all(type: "Resource::Pictura")

      reversible do |dir|
         dir.up do
            qs = PROPS.map do |(name, type)|
               "CREATE INDEX #{name}_index_on_props_resources
                          ON resources (((props ->> '#{name}')::#{type}))
                       WHERE (props ->> '#{name}') IS NOT NULL"
            end.each { |q| ActiveRecord::Base.connection.execute(q) }
         end

         dir.down do
            qs = PROPS.map do |(name, _type)|
               "DROP INDEX IF EXISTS #{name}_index_on_props_resources"
            end.each { |q| ActiveRecord::Base.connection.execute(q) }
         end
      end

      change_column_null :resources, :type, false
      change_column_null :resources, :digest, false
   end
end
