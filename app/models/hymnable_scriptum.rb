class HymnableScriptum < ApplicationRecord
  belongs_to :hymnable, polymorphic: true, inverse_of: :hymnable_scripta
  belongs_to :scriptum
end
