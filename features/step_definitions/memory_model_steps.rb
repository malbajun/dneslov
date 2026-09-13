То('памѧть со заглавом {string} не будє єствовати') do |title|
   memory = Memory.by_title(title).first
   expect(memory).to be_blank
end

То('изнахоѕи памѧти {string} не бѫдє') do |name|
   memories = Memory.by_uno(name)
   expect(memories).to be_blank
end

То('изнахоѕь памѧти {string} бѫдє яко:') do |name, doc_string|
   memory = Memory.by_uno(name).order(:updated_at).last
   expect(memory).to match_record_yaml(doc_string)
end

То(/^свойство '(.*)' памяти "([^"]*)" не может быть пустым$/) do |attr, short_name|
   name = Memory.by_short_name(short_name).first
   expect( name ).to validate_presence_of(attr.to_sym)
end

То(/^выборка "([^"]*)" памяти выбирает поля "([^"]*)"$/) do |scope, field|
   record = Memory.last
   subject = Memory.send( scope, record.send( field ) )
   expect( subject ).to match_array( [ record ] ) ; end

То(/^у памяти "([^"]*)" суть действенными многоимущие свойства:$/) do |short_name, table|
   memory = Memory.by_short_name(short_name).first
   table.rows.flatten.each do |attr|
      expect(memory).to have_many(attr.to_sym)
   end
end
