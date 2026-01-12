# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#


if Order.all.blank?
   ::Tasks.import_orders
end

if Resource.all.blank?
   Resource.transaction do
      data = YAML.load(IO.read(Rails.root.join('db/seeds/resources.yaml')))
      models = data.map { |attrs| Resource.create!(attrs) }
      # select calendary for non calendary books
      # attach to calendary
      models.each do |r|
         Scriptum.find_each do |s|
            s.memoes.find_each do |memo|
               if r.match_year_date(memo.year_date) && r.match_cpages(s) && r.match_scriptum_types(s)
                  s.resource = r
                  s.save!(validate: false)
               end
            end if s.respond_to?(:memoes)
         end
      end
   end
end

if Subject.all.blank?
   data = YAML.load(IO.read(Rails.root.join('db/seeds/subjects.yaml')))
   models = data.map { |attrs| Subject.create!(attrs) }
end

unless Subject.find_by(key: 'РО')
   langs = YAML.load(IO.read(Rails.root.join('db/seeds/languages.yaml')))
   models = langs.map { |attrs| Subject.new(attrs) }
   # fix cps
   AL_MAP = {
      "СР": "СЕ",
      "РУ": "РО",
      "РП": "РУ",
   }

   Subject.transaction do
      Subject.import(models, recursive: true)
      %w(Calendary Name Scriptum Service Description Link).each do |model_name|
         model = model_name.constantize
         AL_MAP.each do |src, tgt|
            model.where(alphabeth_code: src).update_all(alphabeth_code: tgt)
         end
      end
      AL_MAP.each { |src, tgt| Subject.where(key: src).update_all(key: tgt) }
   end
end

if Role.all.blank?
   Role.transaction do
      data = YAML.load(IO.read(Rails.root.join('db/seeds/roles.yaml')))
      models = data.map { |attrs| Role.create!(attrs) }
   end
end
