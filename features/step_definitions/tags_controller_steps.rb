Допустим('єствує мѣта сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }

   FactoryBot.find_create(:tag, **attrs)
end

Допустим('єствує имѧ {string} помѣчено сꙛ {string}') do |nomen, tag_uno|
end

Пусть('не єствує ни єдне мѣте') do
   Tag.destroy_all
end

Если('запытаю створенје изо мѣте {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:tag, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, JSON.generate({ tag: attrs }))
end

То('изнахоѕь мѣте {string} бѫдє яко:') do |uno, doc_string|
   tag =
      Tag.
      by_uno(uno).
      with_title(context).
      with_description(context).
      with_appellation(context).
      order(:updated_at).
      last

   expect(tag).to match_record_yaml(doc_string)
end

То('изнахоѕь мѣте {string} бѫдє єствовати') do |uno|
   tags = Tag.by_uno(uno)

   expect(tags).to_not be_blank
end

То('изнахоѕи мѣте {string} не бѫдє') do |uno|
   tags = Tag.by_uno(uno)

   expect(tags).to be_blank
end

Если('запытаю одсланје мѣте в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:tag, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, JSON.generate({ tag: attrs }))
end
