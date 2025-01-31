class Transcript < Scriptum
   belongs_to :scribable, polymorphic: true
end
