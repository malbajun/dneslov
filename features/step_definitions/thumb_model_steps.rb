Допустим('есть личинка {string} для события {string}') do |uid, event_title|
   FactoryBot.create(:roundel, uid: uid, event_title: event_title)
end

То('свойство {string} личинки {string} не может быть пустым') do |attr, uid|
   roundel = Roundel.by_uid(uid).first
   expect(roundel).to validate_presence_of(attr.to_sym)
end

То('свойство {string} личинки {string} есть отношение к описываемому') do |prop, uid|
   roundel = Roundel.by_uid(uid).first
   expect(roundel).to belong_to(prop)
end

Допустим('создадим новую личинку с полями:') do |table|
   attrs = table.rows_hash.map { |attr, value| [ attr, YAML.load(value) ] }.to_h
   FactoryBot.create(:roundel, attrs)
end

То('личинка {string} будет существовать') do |uid|
   roundel = Roundel.by_uid(uid).first
   expect(roundel).to be_present
end
