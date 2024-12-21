# Roundel class is keeping a roundel as thumbnail for an object
# roundelable is reference to a class: event, memory, or calendary
# uid - uid of the roundel to address to
#
class Roundel < ApplicationRecord
   mount_base64_uploader :image, RoundelUploader
   process_in_background :image
   store_in_background :image

   belongs_to :roundelable, polymorphic: true
   belongs_to :event, -> { joins(:roundels).where(roundels: { roundelable_type: "Event" }) }, foreign_key: 'roundelable_id'
   belongs_to :memory, -> { joins(:roundels).where(roundels: { roundelable_type: "Memory" }) }, foreign_key: 'roundelable_id'

   validates_presence_of :uid, :image
   validates_uniqueness_of :digest, on: :create
   validates_uniqueness_of :uid, :url
   validates :image, presence: true, on: :create, file_size: { less_than: 1.megabytes },
      size: { height: { min: 400 }, ratio: { range: (1.0..1.0) }}

   scope :by_uid, ->(uid) { where(uid: uid) }
   scope :by_roundelable_name, ->(name) do
      if /(?<short_name>.*)#(?<event>.*)/ =~ name
         joins(:event).merge(Event.by_did_and_short_name(event, short_name))
      else
         sub = m =~ /^\d+$/ ? Memory.where(id: name) : Memory.by_token(name)

         joins(:memory).merge(sub.reorder(""))

      end
   end

   before_validation :fill_in_uid
   before_validation :fill_in_digest, :fill_in_url, if: -> { image.file }

   delegate :width, :height, to: :image

   # callbacks
   def fill_in_digest
      self.digest ||= Digest::SHA2.hexdigest(IO.read(image.file.file))
   end

   def fill_in_uid
      self.uid ||= SecureRandom.uuid
   end

   def fill_in_url
      self.url = File.join *[image.asset_host.to_s, image.store_dir, image.filename]
   end

   # assignments
   def roundelable_name= value
      @roundelable_name = value

      self.roundelable_id, self.roundelable_type =
         if /(?<name>.*)#(?<event>.*)/ =~ @roundelable_name
            [Event.by_did_and_short_name(event, name).first&.id, "Event"]
         else
            [Memory.by_short_name(value).first&.id, "Memory"]
         end

      value
   end

   def roundelable_name
      @roundelable_name ||=
         if roundelable_type == 'Memory'
            roundelable.short_name
         elsif roundelable_type == 'Event'
            "#{roundelable.memory.short_name}##{roundelable.id}"
         end
   end

   def root_memory
      @root_memory ||=
         if roundelable_type == 'Memory'
            roundelable
         elsif roundelable_type == 'Event'
            roundelable.memory
         end
   end

   def event_did
      @event ||=
         if roundelable_type == 'Event'
            roundelable.id
         end
   end

   def memory_short_name
      root_memory.short_name
   end
end
