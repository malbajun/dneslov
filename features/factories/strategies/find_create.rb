class FindCreateStrategy
   def initialize
      @strategy = FactoryBot.strategy_by_name(:find_build).new
   end

   delegate :association, to: :@strategy

   def result e
      value = @strategy.result(e)

      value.save!

      value
   end

   def to_sym
      :find_create
   end
end

FactoryBot.register_strategy(:find_create, FindCreateStrategy)
