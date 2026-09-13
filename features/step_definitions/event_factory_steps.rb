Допустим('єствує сꙛбытє {string} для памѧти {string}') do |title, memory_title|
   FactoryBot.create(:event, title: title, memory_title: memory_title)
end

Если('створиме нове сꙛбыте сꙛ полями:') do |table|
   attrs = table.rows_hash.map { |attr, value| [ attr, YAML.load(value) ] }.to_h

   sample { try_create(:event, **attrs) }
end

Если('покушамо створити нове сꙛбытє сꙛ невѣрным описом') do
   sample { try_create :event, :with_invalid_description }
end
