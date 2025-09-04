Допустим('єствує изнахоѕь сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }
   FactoryBot.create(:resource, **attrs)
end

Пусть('не єствує ни єдне изнахоѕи') do
   Resource.destroy_all
end

Если('запытаю створенје изнахоѕи в изо {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:resource, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = post(path, JSON.generate({ resource: attrs }))
end

То('изо изнахоѕи {string} бѫдє яко:') do |name, doc_string|
   resource = Resource.by_uno(name).order(:updated_at).last
   expect(resource).to match_record_yaml(doc_string)
end

То('изо изнахоѕи {string} не бѫдє') do |name|
   memories = Resource.by_uno(name)
   expect(memories).to be_blank
end

Если('запытаю одсланје изнахоѕи в изо {string} сꙛ даными:') do |path, table|
   attrs = FactoryBot.attributes_for(:resource, table.rows_hash.transform_values { |value| YAML.load(value) })
   @response = put(path, JSON.generate({ resource: attrs }))
end

То('изнахоѕь {string} не будє єствовати') do |string|
   resource = Resource.by_title(title).first
   expect(resource).to be_blank
end

Допустим('ествує мнима изнахоѕь') do
   @current = FactoryBot.create(:virtual)
end

То('својство {string} изнахоѕи сєя не можє быти пустꙛ') do |attr|
   expect(@current).to validate_presence_of(attr.to_sym)
end

Допустим('сѫ изнахоѕи мниме {string}') do |count|
   @currents = FactoryBot.create_list(:virtual, count.to_i)
end

То('выборка {string} изнахоѕи избирає поля {string}') do |scope, field|
   subject = Resource.send(scope, @currents.last.send(field)).reload
   expect(subject).to match_array(Resource.where(id: @currents.last.id))
end

То('ѫ изнахоѕи сєя сѫ дѣјсными многоимуча својства:') do |table|
   table.rows.flatten.each do |attr|
      expect(@current).to have_many(attr.to_sym)
   end
end
