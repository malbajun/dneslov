class CreateAudios < ActiveRecord::Migration[7.0]
   def change
      create_table :audios do |t|
         t.uuid :uid, index: { unique: true }, null: false, comment: "Заєдньн опознач"
         t.binary :digest, index: { unique: true }, null: false, comment: "Броєсть єднотна"
         t.string :url, index: { unique: true }, null: false, comment: "Квѧзка єднотна"
         t.string :kind, comment: "Род записа"
         t.string :audio, null: false, comment: "Звѫчєва внутреня дана"
         t.jsonb :meta, index: { using: :gin }, default: {}, comment: "Наддана звѫчєва"
         t.boolean "audio_processing", default: false, null: false, comment: "Звѫчєва обработка"
         t.string "audio_tmp", comment: "Врѣмянка звѫчєва"

         t.timestamps
      end
   end
end
