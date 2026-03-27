class Taggable < ApplicationRecord
   belongs_to :taggable, polymorphic: true
   belongs_to :tag, counter_cache: :tagged_count
end
