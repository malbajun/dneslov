Допустим('єствує вещь {string} яко {string}') do |title, type|
   FactoryBot.create(:item, title: title, item_type_title: type)
end

Допустим('єствує взор вещи {string} яко {string}') do |title, _code|
   FactoryBot.find_create(:item_type, title: title)
end

Допустим('єствує вещь сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }

   FactoryBot.find_create(:item, **attrs)
end
