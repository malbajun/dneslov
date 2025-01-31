class ScriptumScribable < ActiveRecord::Base
   enum :kind, { source: "source", target: "target" }, default: :source, validate: true

   belongs_to :scriptum
   belongs_to :scribable, polymorphic: true
end
