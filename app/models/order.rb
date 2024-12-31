class Order < Memory
   has_many :memo_orders
   has_many :memoes, through: :memo_orders
   has_many :memories, through: :slug
end
