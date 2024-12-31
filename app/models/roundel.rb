# Roundel class is keeping a roundel as thumbnail for an object
# roundelable is reference to a class: event, memory, or calendary
# uid - uid of the roundel to address to
#
class Roundel < ApplicationRecord
   mount_base64_uploader :image, RoundelUploader
   process_in_background :image
   store_in_background :image

   belongs_to :roundelable, polymorphic: true
   belongs_to :event, -> { left_outer_joins(:roundels).where(roundels: { roundelable_type: "Event" }) }, foreign_key: 'roundelable_id'
   belongs_to :memory, -> { left_outer_joins(:roundels).where(roundels: { roundelable_type: "Memory" }) }, foreign_key: 'roundelable_id'

   default_scope { order(created_at: :asc) }

   scope :by_uid, ->(uid) { where(uid: uid) }
   scope :by_id, ->(id) { where(id: id) }
   scope :by_memory_id, ->(id) do
      this = table.table_alias || table.name
      join = "LEFT OUTER JOIN events AS #{this}_events ON #{this}_events.id = roundels.roundelable_id AND roundels.roundelable_type = 'Event'
              LEFT OUTER JOIN memories AS #{this}_memories ON #{this}_memories.id = roundels.roundelable_id AND roundels.roundelable_type = 'Memory'"

      wherec = "#{this}_events.memory_id = ? OR #{this}_memories.id = ?"

      joins(join).where(wherec, id, id)
   end

   # search by short_name or slug with/out event name or id
   scope :by_roundelable_name, ->(name_in) do
      if /(?<name>.*)#(?<event>.*)/ =~ name_in
         by_uno(name).joins(:event).merge(Event.by_uno(event))
      else
         by_uno(name_in)
      end
   end

   # title with or without event
   scope :by_default_or_specific_title, ->(title) do
      this = table.table_alias || table.name
      sub_m =
         case title
         when /^[а-яё0-9]+$/
            Memory.by_slug(title)
         else
            Memory.by_title(title)
         end
      sub_e = Event.by_of_two_title(title)

      left_outer_joins(:event, :memory).
      joins(sub_m.joins_values, sub_e.joins_values).
         merge(sub_m.reorder("")).or(merge(sub_e)).
         distinct
   end

   scope :by_memory, ->(m) do
      case m.to_s
      when /^\s*$/
         none
      when /^\d+$/
         by_memory_id(m)
      else
         by_default_or_specific_title(m)
      end
   end

   scope :by_event, ->(e) do
      if e.respond_to?(:arel)
         where(roundels: {roundelable_type: "Event", roundelable_id: e.select(:id) })
      else
         joins(:event).merge(Event.by_uno(e).reorder(""))
      end
   end

   # by universal numbering object: by id, by slug, by short_name or by title
   scope :by_uno, ->(uno) do
      case uno
      when /^\s*$/
         none
      when /^\d+$/
         by_memory_id(uno)
      when /^.+-.+-.+-.+-.+$/
         by_uid(uno)
      when /(.+)#(.+)/
         by_roundelable_name(uno)
      else
         by_default_or_specific_title(uno)
      end
   end

   validates_presence_of :uid, :image
   validates_uniqueness_of :digest, on: :create
   validates_uniqueness_of :uid, :url
   validates :image, presence: true, on: :create, file_size: { less_than: 1.megabytes },
      size: { height: { min: 400 }, ratio: { range: (1.0..1.0) }}

   before_validation :fill_in_uid
   before_validation :fill_in_digest, :fill_in_url, if: -> { image.file && File.exist?(image.file.file) }

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

   def event_id
      @event ||=
         if roundelable_type == 'Event'
            roundelable.id
         end
   end

   def memory_short_name
      root_memory.short_name
   end
end
