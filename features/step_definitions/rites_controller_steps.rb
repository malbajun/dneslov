Пусть('не єствує ни єдна чина') do
   Rite.destroy_all
end

Пусть('сѫ чини:') do |doc_string|
   hash = YAML.load(doc_string)
   hash.each { |attrs| FactoryBot.create(:rite, attrs) }
end

Если('запытаю створенје изнахоѕи чина {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:rite, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, { rite: attrs })
end

То('изнахоѕь чина {string} бѫдє яко:') do |uno, doc_string|
   rite = Rite.by_uno(uno).first
   expect(rite).to match_record_yaml(doc_string)
end

То('изнахоѕи чина {string} не бѫдє') do |uno|
   rite = Rite.by_uno(uno).first
   expect(rite).to be_blank
end

Если('запытаю одсланје чинъ в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:rite, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, { rite: attrs })
end

Пусть('є чин сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }
   @current = FactoryBot.create(:rite, attrs)
end

То('чин {string} не будє єствовати') do |uno|
   rite = Rite.by_uno(uno).first
   expect(rite).to be_blank
end

Пусть('сѫ {string} чинъ') do |num|
   FactoryBot.create_list(:rite, num.to_i)
end

Если('чин {string} єствує') do |uno|
   rite = Rite.by_uno(uno).first
   expect(rite).to_not be_blank
end
