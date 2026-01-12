class AddFieldsToResources < ActiveRecord::Migration[7.0]
   def change
      change_column_null :resources, :digest, true
   end
end
