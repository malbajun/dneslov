Если('запытаю одсланје памѧти в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:memory, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, JSON.generate({ memory: attrs }))
end

Если('запытаю створенје изнахоѕи памѧти {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:memory, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, JSON.generate({ memory: attrs }))
end
