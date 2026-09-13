Допустим('єствує памѧть сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }

   FactoryBot.find_create(:memory, **attrs)
end

Допустим('єствує мѣсто сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }

   FactoryBot.find_create(:place, **attrs)
end

Допустим('єствує чин сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }

   FactoryBot.find_create(:order, **attrs)
end

Допустим('єствує памѧть {string}') do |name|
   FactoryBot.find_create(:memory, short_name: name)
end

Допустим('єствує памѧть {string} сꙛ озом {string}') do |name, number|
   FactoryBot.create(:memory, short_name: name, id: number)
end

Допустим('єствує русьско мѣсто {string}') do |short_name|
   FactoryBot.find_create(:place, short_name: short_name)
end

Пусть('сѫ памѧти:') do |doc_string|
   hash = YAML.load(doc_string)
   hash.each { |attrs| FactoryBot.create(:memory, attrs) }
end

Пусть('сѫ памяти {string}') do |names|
   names.split(/\s*,\s*/).each do |short_name|
      FactoryBot.find_create(:memory, short_name: short_name)
   end
end

Пусть('не єствує ни єдне памѧти') do
   Memory.destroy_all
end
