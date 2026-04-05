Допустим('єствує сꙛбытє {string} ѫ памѧти {string}') do |event_name, short_name|
   FactoryBot.create(:event, title: event_name, memory_title: short_name, place: nil)
end

Допустим('єствує сꙛбытє {string} сꙛ озом {string} ѫ памѧти {string}') do |event_name, id, short_name|
   FactoryBot.create(:event, id: id, title: event_name, memory_title: short_name, place: nil)
end

Допустим('єствує сꙛбытє {string} сꙛ озом {string} ѫ памѧти {string}, коє сѧ случи во {string}') do |title, id, short_name, happened_at|
   FactoryBot.create(:event, id: id, title: title, memory_title: short_name, place: nil, happened_at: happened_at)
end

Допустим('єствує сꙛбытє {string} сꙛ озом {string}, коє сѧ случи во {string}') do |title, id, happened_at|
   FactoryBot.create(:event, id: id, title: title, place: nil, happened_at: happened_at)
end

Допустим('єствує сꙛбытє сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }

   FactoryBot.find_create(:event, **attrs)
end

Пусть('не єствує ни єдне сꙛбытя') do
   Event.destroy_all
end

Если('запытаю створенје изо сꙛбытя {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:event, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, JSON.generate({ event: attrs }))
end

То('изнахоѕь сꙛбытя {string} бѫдє яко:') do |uno, doc_string|
   event =
      Event.
      by_uno(uno).
      with_title(context).
      with_description(context).
      with_memory_short_name(context).
      order(:updated_at).
      last

   expect(event.jsonize).to match_record_yaml(doc_string)
end

То('изнахоѕи сꙛбытя {string} не бѫдє') do |uno|
   events = Event.by_uno(uno)

   expect(events).to be_blank
end

То('изнахоѕь сꙛбытя {string} бѫдє єствовати') do |uno|
   events = Event.by_uno(uno)

   expect(events).to_not be_blank
end

Если('запытаю одсланје сꙛбытя в изнаходь {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:event, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, JSON.generate({ event: attrs }))
end
