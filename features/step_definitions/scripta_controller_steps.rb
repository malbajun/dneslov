Если('запытаю створенје изо письма {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:scriptum, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, JSON.generate({ scriptum: attrs }))
end

Если('запытаю одсланје письма в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:scriptum, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, JSON.generate({ scriptum: attrs }))
end
