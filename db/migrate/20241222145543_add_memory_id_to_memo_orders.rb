class AddMemoryIdToMemoOrders < ActiveRecord::Migration[7.0]
   def change
      safety_assured do
         reversible do |dir|
            dir.up do
               [
        "DELETE FROM memo_orders
               WHERE order_id NOT IN (SELECT id FROM orders)",
             "UPDATE memo_orders
                 SET order_id = memo_orders.order_id + 15000",
              ].each { |q| Order.connection.execute(q) }
            end
         end
      end

      add_foreign_key :memo_orders, :memories, column: :order_id, primary_key: "id", on_delete: :cascade
   end
end
