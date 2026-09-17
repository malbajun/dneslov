Допустим('єствує письмо сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }
   @current = FactoryBot.create(:scriptum, attrs)
end
