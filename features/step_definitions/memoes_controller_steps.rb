Допустим('єствує помин во калѧдарю {string} для сꙛбытја {string}') do |cuno, event_name|
   FactoryBot.create(:memo, calendary_uno: cuno, event_name: event_name)
end

Допустим('єствує помин {string} сꙛ славој {string} во калѧдарю {string} для сꙛбытја {string}') do |title, order, cuno, event_name|
   FactoryBot.create(:memo, calendary_uno: cuno, event_name: event_name, title: title, order_slug: order)
end

Допустим('єствує помин {string} сꙛ славој {string} и замѣткој {string} во калѧдарю {string} для сꙛбытја {string}') do |title, order, note, cuno, event_name|
   FactoryBot.create(:memo, calendary_uno: cuno, event_name: event_name, title: title, note: note, order_slug: order)
end

Пусть('єствує помин {string} сꙛ славој {string} во калѧдарю {string} для сꙛбытја {string} и є включенѫ во собор {string}') do |title, order, cuno, event_name, council_title|
   FactoryBot.create(:memo, calendary_uno: cuno, event_name: event_name, title: title, order_slug: order, council_title: council_title)
end
