module DistinctBy
   extend ActiveSupport::Concern

   def self.included base
      base.class_eval do
         scope :distinct_by, -> *args do
            this = table.table_alias || table.name
            _selector = self.select_values.dup
            if _selector.empty?
               selector = ["ON (#{args.join(', ')}) #{this}.*"]
            else
               selector =
                  if index = _selector.find_index {|x| x =~ /^ON/ }
                     /ON \((?<fields>[^)]+)\)(?<rest>.*)/ =~ _selector[index]
                     new_distinct = "ON (#{(fields.split(/,\s*/) | [args.join(', ')]).join(", ")}) #{rest}"

                     _selector.map.with_index {|x, i| i == index ? new_distinct : x }
                  else
                     sel = _selector.uniq
                     sel.unshift("ON (#{args.join(', ')}) " + sel.shift)

                     sel
                  end
            end

            rela = self.distinct
            rela.select_values = selector
            rela
         end
      end
   end
end
