class CreateAudioAttitudes < ActiveRecord::Migration[7.0]
   def change
      create_table :audio_attitudes do |t|
         t.references :audio, index: true, foreign_key: { on_delete: :cascade }, null: false, comment: "Квѧзка на табеку сꙛ звѫчями"
         t.references :audioable, polymorphic: true, index: true, comment: "Квѧзка на табелке, коє сѧ упоминаѫ во звѫчєх"

         t.jsonb :meta, index: { using: :gin }, default: {}, comment: "Наддана упоминанјев"
         t.path :poses, comment: "Одмѣтке упоминанјев в звѫчю"

         t.timestamps
      end
   end
end
