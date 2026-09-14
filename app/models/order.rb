class Order < Memory
   has_many :memo_orders
   has_many :memoes, through: :memo_orders
   has_many :memories, through: :slug

   scope :with_pure_order, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)

      selector = "#{this}.id,
                  #{this}_#{as}_slugs.text AS _slug,
                  #{this}_#{as}_tweets.text AS _tweet,
                  #{this}_#{as}_short_names.text AS _short_name"

      join = "
                         JOIN event_roles AS #{this}_#{as}_event_roles
                           ON #{this}.id = #{this}_#{as}_event_roles.memory_id
                         JOIN memoes AS #{this}_#{as}_memoes
                           ON #{this}_#{as}_memoes.event_role_id = #{this}_#{as}_event_roles.id
              LEFT OUTER JOIN memo_orders AS #{this}_memo_orders
                           ON #{this}_memo_orders.memo_id = #{this}_memoes.id
              LEFT OUTER JOIN memories AS #{this}_orders
                           ON #{this}_orders.id = #{this}_memo_orders.order_id
                          AND #{this}_orders.type = 'Order'
                         JOIN slugs AS #{this}_#{as}_slugs
                           ON #{this}_#{as}_slugs.sluggable_id = #{this}_orders.id
                          AND #{this}_#{as}_slugs.sluggable_type = 'Memory'
              LEFT OUTER JOIN short_names AS #{this}_#{as}_short_names
                           ON #{this}_orders.id = #{this}_#{as}_short_names.memory_id
                          AND #{this}_#{as}_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_#{as}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
              LEFT OUTER JOIN descriptions AS #{this}_tweets
                           ON #{this}_tweets.describable_id = #{this}_orders.id
                          AND #{this}_tweets.describable_type = 'Memory'
                          AND #{this}_tweets.type = 'Tweet'
                          AND #{this}_tweets.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_tweets.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      group_by = [
         :id,
         "#{this}_#{as}_tweets.text",
         "#{this}_#{as}_short_names.text",
         "#{this}_#{as}_slugs.text",
      ]

      joins(join).select(selector)
   end
end
