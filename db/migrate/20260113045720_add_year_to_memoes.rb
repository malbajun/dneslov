class AddYearToMemoes < ActiveRecord::Migration[7.0]
   def change
      change_table :memoes do |t|
         t.string :happened_at, index: true, comment: "год для помина в калѧдарю"
      end
   end
end
