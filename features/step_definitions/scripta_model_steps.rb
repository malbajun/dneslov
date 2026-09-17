Пусть('не єствує ни єдна письма') do
   Scriptum.destroy_all
end

То('изнахоѕь письма {string} бѫдє яко:') do |uno, doc_string|
   scriptum =
      Scriptum.
      by_uno(uno).
      with_ref_titles(context).
      with_description(context).
      order(:updated_at).
      last

   expect(scriptum.jsonize).to match_record_yaml(doc_string)
end

То('изнахоѕи письма {string} не бѫдє') do |uno|
   scripta = Scriptum.by_uno(uno)

   expect(scripta).to be_blank
end

То('изнахоѕь письма {string} бѫдє єствовати') do |uno|
   scripta = Scriptum.by_uno(uno)

   expect(scripta).to_not be_blank
end
