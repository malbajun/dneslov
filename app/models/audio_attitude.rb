# class keeping attitudes from a class to audio
# audioable is reference to a class: scriptum, patch, or patchset
# audio is reference to an audio
class AudioAttitude < ApplicationRecord
   belongs_to :audioable, polymorphic: true
   belongs_to :audio

   validates_presence_of :audioable, :audio

   def audioable_name= value
      @audioable_name = value

      self.audioable_id, self.audioable_type =
         if /(?<name>.*)#(?<event>.*)/ =~ @audioable_name
            [Event.by_did_and_uno(event, name).first&.id, "Event"]
         else
            [Memory.by_uno(value).first&.id, "Memory"]
         end

      value
   end

   def audioable_name
      @audioable_name ||=
         if audioable_type == 'Memory'
            audioable.short_name
         elsif audioable_type == 'Event'
            "#{audioable.memory.short_name}##{audioable.id}"
         end
   end

   alias_method :attitude_to, :audioable_name
end
