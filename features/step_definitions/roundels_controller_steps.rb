Допустим('єствує личинка сѫ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }
   @current = FactoryBot.create(:roundel, attrs)
end

Пусть('єствує {string} личинка') do |count|
   FactoryBot.create_list(:roundel, count.to_i)
end

Пусть('не єствує ни єдне личинке') do
   Roundel.destroy_all
end

То('изнахоѕь личинци для {string} бѫдє яко:') do |name, doc_string|
   roundel = Roundel.by_roundelable_name(name).order(:updated_at).last
   expect(roundel).to match_record_yaml(doc_string)
end

Если('запытаю створенје изнахоѕи личинци {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:roundel, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, { roundel: attrs })
end

Если('запытаю одсланје личинке в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:roundel, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, { roundel: attrs })
end

То('личинка {string} не будє єствовати') do |name|
   roundel = Roundel.by_roundelable_name(name).first
   expect(roundel).to be_blank
end

То('изнахоѕи личинци {string} не бѫдє') do |name|
   roundel = Roundel.by_roundelable_name(name).first
   expect(roundel).to be_blank
end
