# Audio class is keeping audio resources info
require 'securerandom'

class Audio < ApplicationRecord
   include WithTitles
   include WithDescriptions

   mount_base64_uploader :audio, AudioUploader
   process_in_background :audio
   store_in_background :audio

   has_many :scriptum_scribables, as: :scribable, dependent: :delete_all
   has_many :sources, -> { where.not(type: :Transcript) }, through: :scriptum_scribables, source: :scriptum
   has_many :transcripts, -> { where(type: :Transcript) }, through: :scriptum_scribables, source: :scriptum, dependent: :delete_all
   has_many :attitudes, class_name: :AudioAttitude
   has_many :memories, as: :audioable, through: :attitudes, source: :audioable, source_type: :Memory
   has_many :events, as: :audioable, through: :attitudes, source: :audioable, source_type: :Event

   default_scope { order(created_at: :asc) }

   scope :by_language, ->(l) do
      joins(:titles, :descriptions).where(titles: { language_code: l}).and(where(descriptions: { language_code: l}))
   end

   scope :by_alphabeth, ->(a) do
      joins(:titles, :descriptions).where(titles: { alphabeth_code: a}).and(where(descriptions: { alphabeth_code: a}))
   end

   scope :by_uid, ->(uid) { where(uid: uid) }
   scope :by_id, ->(id) { where(id: id) }
   scope :by_memory_id, ->(id) do
      this = table.table_alias || table.name
      join = "LEFT OUTER JOIN audio_attitudes AS #{this}_attitudes ON #{this}_attitudes.audio_id = #{this}.id
              LEFT OUTER JOIN events AS #{this}_events ON #{this}_events.id = #{this}_attitudes.audioable_id AND #{this}_attitudes.audioable_type = 'Event'
              LEFT OUTER JOIN memories AS #{this}_memories ON #{this}_memories.id = #{this}_attitudes.audioable_id AND #{this}_attitudes.audioable_type = 'Memory'"

      wherec = "#{this}_events.memory_id = ? OR #{this}_memories.id = ?"

      joins(join).where(wherec, id, id)
   end

   # search by short_name or slug with/out event name or id
   scope :by_roundelable_name, ->(name_in) do
      if /(?<name>.*)#(?<event>.*)/ =~ name_in
         by_uno(name).joins(:events).merge(Event.by_uno(event))
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

      left_outer_joins(:events, :memories).
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
         joins(:attitudes).where(audio_attitudes: {audioable_type: "Event", audioable_id: e.select(:id) })
      else
         joins(:events).merge(Event.by_uno(e).reorder(""))
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

   validates_presence_of :kind, :uid, :audio
   validates_uniqueness_of :digest, on: :create
   validates_uniqueness_of :uid, :url
   validates :audio, presence: true, on: :create, file_size: { less_than: 16.megabytes }

   before_validation :fill_in_uid
   before_validation :fill_in_digest, :fill_in_url,
      if: -> { audio.file && File.exist?(audio.file.file) }

   # callbacks
   def fill_in_digest
      self.digest ||= audio.file.instance_variable_get(:@digest)
   end

   def fill_in_uid
      self.uid ||= SecureRandom.uuid
   end

   def fill_in_url
      self.url = File.join *["", audio.store_dir, audio.filename]
   end

   def attitude_to= value
      audioable_name = value&.sub(/\(.*/, '')
      poses_in = value&.gsub(/.*\(|\).*/, '')&.split(/,/)

      if poses_in.present? && audioable_name.present?
         pairs = poses_in.reduce([]) {|r, x| r.blank? || r.last.size > 1 ? r << [x] : r.last << x ; r }
         # [(x1,y1),...]
         poses = "[#{pairs.map { |x| "(#{x.join(',')})" }.join(',')}]"

         attitudes.new(audioable_name: audioable_name, poses: poses)
      end
   end

   def reading
      sources.first&.title
   end

   def reading_in= value
      if reading = Scriptum.where(title: value).where.not(type: "Transcript").first
         self.sources << reading
      else
         errors.add(:sources, "Unable to find abbreviation as: '#{value}'")
      end
   end
end
