class DropNullForDigestInAudios < ActiveRecord::Migration[5.2]
   def change
      change_column_null :audios, :digest, true
   end
end
