class FixScripta < ActiveRecord::Migration[7.0]
   #safety_assured

   def change
      change_table :scripta do |t|
         t.references :prosomeion, index: true, comment: "квѧзка до прогласа"
         t.references :bond_to, index: true, comment: "квѧзка до свѧзочне буке"
         t.references :root, index: true, comment: "квѧзка до корневе буке"
         t.string :bind_kind_name, default: "несвязана", index: true, comment: "взор квѧзке: несвязана, списана, преложена, пресловена"
      end

      reversible do |dir|
         dir.up do
            mm =
               Scriptum.all.map do |s|
                  s.prosomeion = Scriptum.where(title: s.prosomeion_title).first if s.prosomeion_title
                  s.bond_to = Scriptum.where(title: s.ref_title).first if s.ref_title
                  s.bind_kind_name = "списана" if s.ref_title
                  #binding.pry if s.ref_title && !s.bond_to

                  s.valid?
                  s
               end

            mm.group_by {|x| x.title }.each do |title, mmm|
               next unless title
               mmm.sort_by {|x| x.title.size }.reverse.reduce(nil) do |base, m|
                  next m unless base

                  m.assign_attributes(bond_to_id: base.id, bind_kind_name: "списана", title: nil, root_id: base.root_id || base.id)

                  base
               end
            end

            mm.group_by {|x| x.title }.each do |title, mmm|
               if title
                  mmm.each {|m| m.save!(validate: false) }
               else
                  mmm.each {|m| m.destroy }
               end
            end
         end
      end

      remove_columns :scripta, :ref_title, :prosomeion_title
      change_column_null :scripta, :root_id, false
   end
end
