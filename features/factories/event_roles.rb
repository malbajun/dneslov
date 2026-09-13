FactoryBot.define do
  factory :event_role do
    event { nil }
    memory { nil }
    type { "" }
    agonism { "MyString" }
    event_kind { "MyString" }
  end
end
