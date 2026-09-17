FactoryBot.define do
   factory :subject do
      key { 'SubjectKind' }
      kind_code { 'SubjectKind' }
      meta { "{}" }

      transient do
         appellation { nil }
         la { "ру_РУ" }
      end

      after(:build) do |s, e|
         if e.appellation
            l,a = Languageble.la_for_string(e.appellation, e.la[0..1], e.la[3..4])
            s.appellations = build_list(:appellation, 1, text: e.appellation, language_code: l, alphabeth_code: a)
         end
      end
   end

   factory :subject_kind, parent: :subject, class: :Subject do
      key { 'SubjectKind' }
      kind_code { 'SubjectKind' }

      association :kind, factory: :subject, key: "SubjectKind", strategy: :find_build
   end

   factory :event_kind, parent: :subject, class: :Subject do
      key { FFaker::Name.name }
      kind_code { 'EventKind' }

      association :kind, factory: :subject_kind, key: "EventKind", strategy: :find_build
   end

   factory :language, parent: :subject, class: :Subject do
      key { 'ру' }
      kind_code { 'Language' }

      association :kind, factory: :subject_kind, key: "Language", strategy: :find_build
   end

   factory :alphabeth, parent: :subject, class: :Subject do
      key { 'РУ' }
      kind_code { 'Alphabeth' }

      association :kind, factory: :subject_kind, key: "Alphabeth", strategy: :find_build
   end

   factory :name_kind, parent: :subject, class: :Subject do
      key { 'наречёное' }
      kind_code { 'NameKind' }

      association :kind, factory: :subject_kind, key: "NameKind", strategy: :find_build
   end

   factory :tag_kind, parent: :subject, class: :Subject do
      key { 'обычна' }
      kind_code { 'TagKind' }

      association :kind, factory: :subject_kind, key: "TagKind", strategy: :find_build
   end

   factory :rite_bind, parent: :subject, class: :Subject do
      key { 'несвязан' }
      kind_code { 'RiteBind' }

      association :kind, factory: :subject_kind, key: 'RiteBind', strategy: :find_build
   end

   factory :name_bind, parent: :subject, class: :Subject do
      key { 'несвязаное' }
      kind_code { 'NameBind' }

      association :kind, factory: :subject_kind, key: 'NameBind', strategy: :find_build
   end
end
