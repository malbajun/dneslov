Допустим('єствує калѧдарь {string} сꙛ слугом {string} и озом {string}') do |title, slug, id|
   FactoryBot.create(:calendary, :without_titles, title: title, slug: slug, id: id)
end
