class ScriptumScribable < ActiveRecord::Base
   belongs_to :scriptum
   belongs_to :scribable, polymorphic: true
end
