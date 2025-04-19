Допустим('єствує сꙛбытие {string} ѫ памѧти {string}') do |event_name, short_name|
   FactoryBot.create(:event, title: event_name, memory_title: short_name, place: nil)
end

Допустим('єствує сꙛбытие {string} сꙛ озом {string} ѫ памѧти {string}') do |event_name, id, short_name|
   FactoryBot.create(:event, id: id, title: event_name, memory_title: short_name, place: nil)
end

Допустим('єствує сꙛбытие {string} сꙛ озом {string} ѫ памѧти {string}, коє сѧ случи во {string}') do |title, id, short_name, happened_at|
   FactoryBot.create(:event, id: id, title: title, memory_title: short_name, place: nil, happened_at: happened_at)
end

