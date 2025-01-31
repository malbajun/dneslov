class CreateCantoMemories < ActiveRecord::Migration[5.2]
   def change
      create_table :canto_memories, id: :serial do |t|
         t.belongs_to :canto, null: false
         t.belongs_to :memory, null: false

         t.index %i(canto_id memory_id), name: "canto_memories_index", unique: true
      end
   end
end
