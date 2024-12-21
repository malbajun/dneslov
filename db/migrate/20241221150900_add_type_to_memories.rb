class AddTypeToMemories < ActiveRecord::Migration[5.2]
   def change
      change_table :memories do |t|
         t.string :type, index: true, null: false, default: 'Memory'
         t.string :kind, index: true

         t.change_null :short_name, true

         t.remove :order, type: :string
      end

      safety_assured do
         reversible do |dir|
            dir.up do
               [
             ####### groups

               "WITH memories_ids AS (
              SELECT memories.id
                FROM memoes
                JOIN events
                  ON memoes.event_id = events.id
                JOIN memories ON memories.id = events.memory_id),
                     _groups AS (
              SELECT DISTINCT ON (memories.id)
                     memories.id, memories.base_year, memories.short_name, memories.quantity
                FROM memories
                JOIN slugs
                  ON slugs.sluggable_id = memories.id
                 AND 'Memory' = slugs.sluggable_type
                JOIN events
                  ON memories.id = events.memory_id
               WHERE memories.id NOT IN (SELECT * FROM memories_ids)
                 AND memories.short_name NOT IN ('Троица Пресвятая')
                 AND memories.quantity IS NOT NULL)
              UPDATE memories
                 SET type = 'Group'
               WHERE memories.id IN (SELECT id FROM _groups)",

             ####### councils

               "WITH _memory_ids AS (
              SELECT memories.id
                FROM memories, memories AS om
     LEFT OUTER JOIN slugs ON om.id = slugs.sluggable_id
                 AND 'Memory' = slugs.sluggable_type
               WHERE memories.council !~ slugs.text),
                     _slug_ids AS (
              SELECT slugs.id
                FROM slugs
               WHERE slugs.sluggable_id IN (SELECT * FROM _memory_ids)
                 AND 'Memory' = slugs.sluggable_type),
                     _councils AS (
              SELECT DISTINCT ON (memories.id)
                     memories.id, memories.base_year, memories.short_name, memories.quantity
                FROM memories
                JOIN slugs
                  ON slugs.sluggable_id = memories.id
                 AND 'Memory' = slugs.sluggable_type
                JOIN events
                  ON memories.id = events.memory_id
                JOIN memoes
                  ON memoes.event_id = events.id
                JOIN memo_orders
                  ON memoes.id = memo_orders.memo_id
                JOIN slugs AS memo_slugs
                  ON memo_orders.order_id = memo_slugs.sluggable_id
                 AND 'Order' = memo_slugs.sluggable_type
               WHERE (slugs.id IN (SELECT * FROM _slug_ids)
                  OR memories.short_name ~* 'собор')
                 AND memories.short_name NOT IN ('Троица Пресвятая')
                 AND memories.quantity IS NOT NULL)
              UPDATE memories
                 SET type = 'Council'
               WHERE memories.id IN (SELECT id FROM _councils)",

             ####### buildings

               "WITH _memory_ids AS (
              SELECT memories.id
                FROM memories, memories AS om
     LEFT OUTER JOIN slugs ON om.id = slugs.sluggable_id
                 AND 'Memory' = slugs.sluggable_type
               WHERE memories.council !~ slugs.text),
                     _slug_ids AS (
              SELECT slugs.id
                FROM slugs
               WHERE slugs.sluggable_id IN (SELECT * FROM _memory_ids)
                 AND 'Memory' = slugs.sluggable_type),
                     _buildings AS (
              SELECT DISTINCT ON (memories.id)
                     memories.id, memories.base_year, memories.short_name, memories.quantity
                FROM memories
                JOIN slugs
                  ON slugs.sluggable_id = memories.id
                 AND 'Memory' = slugs.sluggable_type
                JOIN events
                  ON memories.id = events.memory_id
                JOIN memoes
                  ON memoes.event_id = events.id
                JOIN memo_orders
                  ON memoes.id = memo_orders.memo_id
                JOIN slugs AS memo_slugs
                  ON memo_orders.order_id = memo_slugs.sluggable_id
                 AND 'Order' = memo_slugs.sluggable_type
                 AND memo_slugs.text IN ('храм')
               WHERE slugs.id IN (SELECT * FROM _slug_ids)
                 AND memories.quantity IS NULL)
              UPDATE memories
                 SET type = 'Building'
               WHERE memories.id IN (SELECT id FROM _buildings)",


             ####### subsisten

             "UPDATE memories
                 SET type = 'Subsisten'
               WHERE memories.short_name IN ('Троица Пресвятая')",

             ####### orders

        "INSERT INTO memories
                     (id, base_year, created_at, updated_at, type)
              SELECT orders.id + 15000, 0, NOW(), NOW(), 'Order'
                FROM orders",

             "UPDATE descriptions
                 SET describable_type = 'Memory',
                     describable_id = descriptions.describable_id + 15000
                FROM orders
               WHERE descriptions.describable_type = 'Order'
                 AND descriptions.describable_id IN (SELECT id FROM orders)",

             ####### places

               "WITH _memory_ids AS (
              SELECT memories.id
                FROM memories, memories AS om
     LEFT OUTER JOIN slugs ON om.id = slugs.sluggable_id
                 AND 'Memory' = slugs.sluggable_type
               WHERE memories.council !~ slugs.text),
                     _slug_ids AS (
              SELECT slugs.id
                FROM slugs
               WHERE slugs.sluggable_id IN (SELECT * FROM _memory_ids)
                 AND 'Memory' = slugs.sluggable_type),
                     _places AS (
              SELECT DISTINCT ON (memories.id)
                     memories.id, memories.base_year, memories.short_name, memories.quantity
                FROM memories
                JOIN slugs
                  ON slugs.sluggable_id = memories.id
                 AND 'Memory' = slugs.sluggable_type
                JOIN events
                  ON memories.id = events.memory_id
                JOIN memoes
                  ON memoes.event_id = events.id
                JOIN memo_orders
                  ON memoes.id = memo_orders.memo_id
                JOIN slugs AS memo_slugs
                  ON memo_orders.order_id = memo_slugs.sluggable_id
                 AND 'Order' = memo_slugs.sluggable_type
                 AND memo_slugs.text IN ('место', 'обит', 'град', 'мір')
               WHERE slugs.id IN (SELECT * FROM _slug_ids)
                 AND memories.quantity IS NULL)
              UPDATE memories
                 SET type = 'Place'
               WHERE memories.id IN (SELECT id FROM _places)",

        "INSERT INTO memories
                     (id, base_year, created_at, updated_at, type)
              SELECT places.id + 20000, 0, NOW(), NOW(), 'Place'
                FROM places",

             "UPDATE descriptions
                 SET describable_type = 'Memory',
                     describable_id = descriptions.describable_id + 20000
                FROM places
               WHERE descriptions.describable_type = 'Place'
                 AND descriptions.describable_id IN (SELECT id FROM places)",

             ####### identities

               "WITH _memory_ids AS (
              SELECT memories.id
                FROM memories, memories AS om
     LEFT OUTER JOIN slugs ON om.id = slugs.sluggable_id
                 AND 'Memory' = slugs.sluggable_type
               WHERE memories.council !~ slugs.text),
                     _slug_ids AS (
              SELECT slugs.id
                FROM slugs
               WHERE slugs.sluggable_id IN (SELECT * FROM _memory_ids)
                 AND 'Memory' = slugs.sluggable_type),
                     _identities AS (
              SELECT DISTINCT ON (memories.id)
                     memories.id, memories.base_year, memories.short_name, memories.quantity
                FROM memories
                JOIN slugs
                  ON slugs.sluggable_id = memories.id
                 AND 'Memory' = slugs.sluggable_type
                JOIN events
                  ON memories.id = events.memory_id
                JOIN memoes
                  ON memoes.event_id = events.id
                JOIN memo_orders
                  ON memoes.id = memo_orders.memo_id
                JOIN slugs AS memo_slugs
                  ON memo_orders.order_id = memo_slugs.sluggable_id
                 AND 'Order' = memo_slugs.sluggable_type
                 AND memo_slugs.text NOT IN ('храм', 'место', 'град', 'обит', 'древо', 'вещь', 'оспс', 'обрбо', 'оник', 'озпр', 'обр')
               WHERE slugs.id IN (SELECT * FROM _slug_ids)
                 AND memories.quantity IS NULL)
              UPDATE memories
                 SET type = 'Identity'
               WHERE memories.id IN (SELECT id FROM _identities)",

             ####### concepts

               "WITH _memory_ids AS (
              SELECT memories.id
                FROM memories, memories AS om
     LEFT OUTER JOIN slugs ON om.id = slugs.sluggable_id
                 AND 'Memory' = slugs.sluggable_type
               WHERE memories.council !~ slugs.text),
                     _slug_ids AS (
              SELECT slugs.id
                FROM slugs
               WHERE slugs.sluggable_id IN (SELECT * FROM _memory_ids)
                 AND 'Memory' = slugs.sluggable_type),
                     _concepts AS (
              SELECT DISTINCT ON (memories.id)
                     memories.id, memories.base_year, memories.short_name, memories.quantity
                FROM memories
                JOIN slugs
                  ON slugs.sluggable_id = memories.id
                 AND 'Memory' = slugs.sluggable_type
                JOIN events
                  ON memories.id = events.memory_id
                JOIN memoes
                  ON memoes.event_id = events.id
                JOIN memo_orders
                  ON memoes.id = memo_orders.memo_id
                JOIN slugs AS memo_slugs
                  ON memo_orders.order_id = memo_slugs.sluggable_id
                 AND 'Order' = memo_slugs.sluggable_type
                 AND memo_slugs.text IN ('сбт')
                 AND slugs.text NOT IN ('бдц')
               WHERE slugs.id IN (SELECT * FROM _slug_ids)
                 AND memories.quantity IS NULL)
              UPDATE memories
                 SET type = 'Concept'
               WHERE memories.id IN (SELECT id FROM _concepts)",

             ####### items

               "WITH _memory_ids AS (
              SELECT memories.id
                FROM memories, memories AS om
     LEFT OUTER JOIN slugs ON om.id = slugs.sluggable_id
                 AND 'Memory' = slugs.sluggable_type
               WHERE memories.council !~ slugs.text),
                     _slug_ids AS (
              SELECT slugs.id
                FROM slugs
               WHERE slugs.sluggable_id IN (SELECT * FROM _memory_ids)
                 AND 'Memory' = slugs.sluggable_type),
                     _items AS (
              SELECT DISTINCT ON (memories.id)
                     memories.id, memories.base_year, memories.short_name, memories.quantity
                FROM memories
                JOIN slugs
                  ON slugs.sluggable_id = memories.id
                 AND 'Memory' = slugs.sluggable_type
                JOIN events
                  ON memories.id = events.memory_id
                JOIN memoes
                  ON memoes.event_id = events.id
                JOIN memo_orders
                  ON memoes.id = memo_orders.memo_id
                JOIN slugs AS memo_slugs
                  ON memo_orders.order_id = memo_slugs.sluggable_id
                 AND 'Order' = memo_slugs.sluggable_type
                 AND memo_slugs.text IN ('вещь', 'оспс', 'обрбо', 'оник', 'озпр')
               WHERE slugs.id IN (SELECT * FROM _slug_ids)
                 AND memories.quantity IS NULL)
              UPDATE memories
                 SET type = 'Thing'
               WHERE memories.id IN (SELECT id FROM _items)",

              ].each { |q| Order.connection.execute(q) }
            end
         end
      end
   end
end
