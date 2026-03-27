module FactoryBot
   # @api private
   class AttributeAssigner
      def object
         @evaluator.instance = build_class_instance
         build_class_instance.tap do |instance|
            attributes_to_set_on_instance.each do |attribute|
               if instance.respond_to?("#{attribute}=")
                  instance.public_send("#{attribute}=", get(attribute))
               else
                  instance.instance_variable_set(:"@#{attribute}", get(attribute))
               end
               @attribute_names_assigned << attribute
            end
         end
      end
   end
end
