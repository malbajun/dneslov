Допустим('є звѫчє сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }
   @current = FactoryBot.create(:audio, attrs)
end

Пусть('не єствує ни єднѣ звѫкѣ') do
   Audio.delete_all
end

Пусть('сѫ звѫця:') do |doc_string|
   hash = YAML.load(doc_string)
   hash.each { |attrs| FactoryBot.create(:audio, attrs) }
end

Если('запытаю створенје изнахоѕи звѫкѣ {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:audio, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, { audio: attrs })
end

То('изнахоѕь звѫкѣ {string} бѫдє яко:') do |title, doc_string|
   audio = Audio.by_title(title).first
   expect(audio).to match_record_yaml(doc_string)
end

То('изнахоѕи звѫкѣ {string} не бѫдє') do |title|
   audio = Audio.by_title(title).first
   expect(audio).to be_blank
end

Если('запытаю одсланје звѫкё в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:audio, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, { audio: attrs })
end

То('звѫчє {string} не будє єствовати') do |title|
   audio = Audio.by_title(title).first
   expect(audio).to be_blank
end

