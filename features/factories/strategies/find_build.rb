class FindBuildStrategy
   def initialize
      @strategy = FactoryBot.strategy_by_name( :build ).new
   end

   delegate :association, to: :@strategy

   def result e
      aa = e.instance_variable_get(:@attribute_assigner)
      klass = aa.instance_variable_get(:@build_class)
      attrs_in = e.instance_variable_get(:@evaluator)&.instance_variable_get(:@overrides) || {}

      instance_pre = klass.new
      ignored = aa.instance_variable_get(:@attribute_list).ignored.map {|x|x.name}
      attrs = attrs_in.group_by do |(key,_)|
         if instance_pre.respond_to?("#{key}=")
            true
         elsif !ignored.include?(key)
            false
         end
      end.map {|(x, y)| [x, y.to_h] }.to_h

      instance = attrs[true] && find(attrs[true], klass) || @strategy.result(e)

      attrs[false].each do |key, value|
         instance.instance_variable_set("@#{key}", value)
      end if attrs[false]

      instance
   end

   def find attrs_in, klass
      rela =
         attrs_in.reduce(klass.default_scoped) do |rela, (attr, value)|
            if klass.respond_to?("by_#{attr}")
               rela.send("by_#{attr}", value)
            else
               rela.where(attr => value)
            end
         end

      rela.first
   end
end

FactoryBot.register_strategy(:find_build, FindBuildStrategy)
