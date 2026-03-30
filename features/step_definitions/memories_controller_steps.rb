Допустим('єствує памѧть сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }

   FactoryBot.find_create(:memory, **attrs)
end

Допустим('єствує памѧть {string}') do |name|
   FactoryBot.find_create(:memory, short_name: name)
end

Допустим('єствує памѧть {string} сꙛ озом {string}') do |name, number|
   FactoryBot.create(:memory, short_name: name, id: number)
end

Пусть('сѫ памѧти:') do |doc_string|
   hash = YAML.load(doc_string)
   hash.each { |attrs| FactoryBot.create(:memory, attrs) }
end

Пусть('не єствує ни єдне памѧти') do
   Memory.destroy_all
end

Если('запытаю одсланје памѧти в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:memory, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, JSON.generate({ memory: attrs }))
end

То('памѧть {string} не будє єствовати') do |title|
   memory = Memory.by_title(title).first
   expect(memory).to be_blank
end

Если('запытаю створенје изнахоѕи памѧти {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:memory, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, JSON.generate({ memory: attrs }))
end

То('изнахоѕь памѧти {string} бѫдє яко:') do |name, doc_string|
   memory = Memory.by_uno(name).order(:updated_at).last
   expect(memory).to match_record_yaml(doc_string)
end

То('изнахоѕи памѧти {string} не бѫдє') do |name|
   memories = Memory.by_uno(name)
   expect(memories).to be_blank
end

Допустим('єствує слава сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }
   FactoryBot.create(:order, attrs)
end
