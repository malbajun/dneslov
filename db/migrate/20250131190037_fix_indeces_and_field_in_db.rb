class FixIndecesAndFieldInDb < ActiveRecord::Migration[7.0]
   disable_ddl_transaction!
   safety_assured

   def change
      change_column(:calendaries, :place_id, :bigint)
      add_index(:calendaries, :place_id, if_not_exists: true, algorithm: :concurrently)
      change_column(:canto_memories, :canto_id, :bigint)
      change_column(:canto_memories, :memory_id, :bigint)
      add_index(:canto_memories, :canto_id, if_not_exists: true, algorithm: :concurrently)
      add_index(:canto_memories, :memory_id, if_not_exists: true, algorithm: :concurrently)
      change_column(:descriptions, :describable_id, :bigint)
      change_column_default(:descriptions, :describable_type, "Memory")
      change_column_null(:descriptions, :describable_type, false)
      add_index(:descriptions, :describable_id, if_not_exists: true, algorithm: :concurrently)
      change_column(:events, :memory_id, :bigint)
      change_column(:events, :place_id, :bigint)
      change_column(:events, :item_id, :bigint)
      change_column(:items, :item_type_id, :bigint)
      add_index(:items, :item_type_id, if_not_exists: true, algorithm: :concurrently)
      change_column(:links, :info_id, :bigint)
      change_column(:memoes, :calendary_id, :bigint)
      change_column(:memoes, :event_id, :bigint)
      add_index(:memories, :base_year, if_not_exists: true, algorithm: :concurrently)
      add_index(:memories, :council, if_not_exists: true, algorithm: :concurrently)
      change_column_comment(:memories, :kind, "Вид связки: источник (Source) для списков икон, опора (Base) - иконы личностей, подобие (Similar) - для установления подобия иконы иной иконевладелец (Host) - для владельцев предметов")
      change_column_comment(:memory_binds, :kind, "Вид связки: источник (Source) для списков икон, опора (Base) - иконы личностей, подобие (Similar) - для установления подобия иконы иной иконевладелец (Host) - для владельцев предметов")
      change_column(:memory_names, :memory_id, :bigint)
      change_column(:memory_names, :nomen_id, :bigint)
      add_index(:memory_names, :state_code, if_not_exists: true, algorithm: :concurrently)
      add_index(:nomina, :bond_to_id, if_not_exists: true, algorithm: :concurrently)
      change_column(:service_scripta, :service_id, :bigint)
      change_column(:service_scripta, :scriptum_id, :bigint)
      change_column(:services, :info_id, :bigint)
      change_column(:slugs, :sluggable_id, :bigint)
      #raise
   end
end
