Допустим('єствує ѧзык {string} яко {string}') do |name, code|
   FactoryBot.find_create(:language, key: code, name: name)
end

Допустим('єствує азбука {string} яко {string}') do |name, code|
   FactoryBot.find_create(:alphabeth, key: code, name: name)
end

Допустим("єствує ѧзык {string}") do |string|
   FactoryBot.find_create(:language, key: string)
end

Допустим("єствує азбука {string}") do |string|
   FactoryBot.find_create(:alphabeth, key: string)
end

Допустим("єствує взор сꙛбытя {string} яко {string}") do |name, code|
   FactoryBot.find_create(:event_kind, key: code, name: name)
end

Допустим("сѫчвуѫ сꙛбытя {string}") do |string|
   string.split(",").each do |key|
      FactoryBot.find_create(:event_kind, key: key.strip).save!
   end
end

Допустим("есть вид имени {string}") do |string|
   FactoryBot.find_create(:name_kind, key: string).save!
end

Допустим("есть виды имени {string}") do |string|
   string.split(",").each do |key|
      FactoryBot.find_create(:name_kind, key: key.strip)
   end
end

Допустим("есть вид связки имени {string}") do |string|
   FactoryBot.find_create(:name_bind, key: string)
end

Допустим("є вид квѧзке чина {string}") do |string|
   FactoryBot.find_create(:rite_bind, key: string)
end

Допустим("есть виды связки имени {string}") do |string|
   string.split(",").each do |key|
      FactoryBot.find_create(:name_kind, key: key.strip)
   end
end

Допустим('єствує вид мѣте {string} яко {string} во азѧте {string}') do |kind, appel, la|
   FactoryBot.find_create(:tag_kind, key: kind, appellation: appel, la: la)
end

Допустим("єствує вид мѣте {string}") do |string|
   FactoryBot.find_build(:tag_kind, key: string).save!
end

Допустим('єствує прѣдмѣт сꙛ даными:') do |table|
   attrs = table.rows_hash.transform_values { |value| YAML.load(value) }
   FactoryBot.find_create(:subject, **attrs)
end
