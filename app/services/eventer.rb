# call as rake dneslov:event:merge
# or
# rake dneslov:event:merge[собор]
#
class Eventer
   attr_reader :slugs

   def initialize slugs: nil
      @slugs = slugs || []
   end

   def merge
      EventRole.transaction do
         memories = slugs.any? ? Memory.council.by_slug(slugs) : Memory.council

         memories.find_each do |memory|
            memory.events.find_each do |event|
               event.bond_event_roles.find_each do |event_role|
                  if event_role.event_kind_code == event.kind_code
                     event_role.update!(event_id: event.id)
                  end
               end
            end
         end

         # remove empty events
         Event.where.not(id: EventRole.select(:event_id)).destroy_all
      end
   end
end
