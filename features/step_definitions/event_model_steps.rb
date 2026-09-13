Допустим('установиме причу сꙛбытя') do
   subject { Event.new }
end

То('својство {string} приче є одношенєм до приче {string}') do |prop, model|
   expect(subject).to belong_to(prop.gsub(/\s+/, '_')).class_name(model.constantize)
end

То('својство {string} приче є одношенєм до описуєма') do |prop|
   expect(subject).to belong_to(prop)
end

То('сꙛбытє {string} бѫдє сѫствовати') do |happened_at|
   expect(Event.where(happened_at: happened_at)).to be_empty
end

Допустим('својства {string} приче не могѫ быти пустыми') do |attrs|
   attrs.split(/,\s*/).each do |attr|
      expect(subject).to validate_presence_of(attr.to_sym)
   end
end

Допустим('сꙛбытє имає родъ {string} для слѣдѫчых столбцов:') do |kind, table|
   table.hashes.map(&:values).flatten.each do |attr|
      expect(subject).to have_db_column(attr).of_type(kind)
   end
end
