# Picture class is keeping image resources info
require 'securerandom'

class Picture < ApplicationRecord
   extend TotalSize
   include WithTitles
   include WithDescriptions

   mount_base64_uploader :image, ImageUploader
   process_in_background :image
   store_in_background :image

   has_many :attitudes, class_name: :ImageAttitude
   has_many :memories, as: :imageable, through: :attitudes, source: :imageable, source_type: :Memory
   has_many :events, as: :imageable, through: :attitudes, source: :imageable, source_type: :Event

   default_scope { order(updated_at: :desc) }

   scope :all_pictures, ->() { reorder(updated_at: :desc) }

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
      join = "           JOIN image_attitudes AS #{this}_attitudes
                           ON #{this}_attitudes.picture_id = #{this}.id
              LEFT OUTER JOIN event_roles AS #{this}_event_roles
                           ON #{this}_event_roles.event_id = #{this}_attitudes.imageable_id
                          AND #{this}_attitudes.imageable_type = 'Event'
              LEFT OUTER JOIN memories AS #{this}_memories
                           ON #{this}_memories.id = #{this}_attitudes.imageable_id
                          AND #{this}_attitudes.imageable_type = 'Memory'"

      wherec = "#{this}_event_roles.memory_id = ? OR #{this}_memories.id = ?"

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
         when Slug::RE
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
         joins(:attitudes).where(image_attitudes: {imageable_type: "Event", imageable_id: e.select(:id) })
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
      when /^.+-.+-.+-.+-.+|[a-f0-9]{32}$/
         by_uid(uno)
      when /(.+)#(.+)/
         by_roundelable_name(uno)
      else
         by_default_or_specific_title(uno)
      end
   end

   scope :with_attitudes_to, -> context do
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      this = table.table_alias || table.name
      language_codes = [context[:text_language] || context[:text_languages]].flatten
      alphabeth_codes = [context[:codes] || context[:text_language] || Languageble.alphabeth_list_for(language_codes)].flatten

      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "COALESCE((WITH __#{as} AS (
                       SELECT DISTINCT ON(slug, event_id) 
                              #{this}_#{as}_slugs.text AS slug,
                              #{this}_#{as}_short_names.text AS memory_title,
                              COALESCE(#{this}_#{as}_event_titles.text, #{as}_#{this}_default_titles.text, '') AS event_title,
                              #{this}_#{as}_event_roles.event_id AS event_id
                         FROM image_attitudes
              LEFT OUTER JOIN event_roles AS #{this}_#{as}_event_roles
                           ON image_attitudes.imageable_id = #{this}_#{as}_event_roles.event_id
                          AND image_attitudes.imageable_type = 'Event'
                         JOIN slugs AS #{this}_#{as}_slugs
                           ON (#{this}_#{as}_slugs.sluggable_id = image_attitudes.imageable_id
                          AND 'Memory' = image_attitudes.imageable_type
                           OR #{this}_#{as}_slugs.sluggable_id = #{this}_#{as}_event_roles.memory_id)
                          AND #{this}_#{as}_slugs.sluggable_type = 'Memory'

                         JOIN short_names AS #{this}_#{as}_short_names
                           ON image_attitudes.imageable_id = #{this}_#{as}_short_names.memory_id
                          AND image_attitudes.imageable_type = 'Memory'
                          AND #{this}_#{as}_short_names.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_#{as}_short_names.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')

              LEFT OUTER JOIN descriptions AS #{this}_#{as}_event_titles
                           ON #{this}_#{as}_event_titles.describable_id = #{this}_#{as}_event_roles.event_id
                          AND #{this}_#{as}_event_titles.describable_type = 'Event'
                          AND #{this}_#{as}_event_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{this}_#{as}_event_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                          AND #{this}_#{as}_event_titles.type = 'Title'

              LEFT OUTER JOIN subjects AS #{this}_#{as}_kinds
                           ON #{this}_#{as}_event_roles.event_kind_code = #{this}_#{as}_kinds.key
              LEFT OUTER JOIN descriptions AS #{as}_#{this}_default_titles
                           ON #{this}_#{as}_kinds.id = #{as}_#{this}_default_titles.describable_id
                          AND #{as}_#{this}_default_titles.describable_type = 'Subject'
                          AND #{as}_#{this}_default_titles.type = 'Appellation'
                          AND #{as}_#{this}_default_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_#{this}_default_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')
                          WHERE #{this}.id = image_attitudes.picture_id)

                       SELECT jsonb_agg(__#{as})
                         FROM __#{as}), '[]'::jsonb) AS _#{as}"

      select(selector).group(:id)
   end

   validates_presence_of :type, :uid, :image
   validates_uniqueness_of :digest, on: :create
   validates_uniqueness_of :uid, :url, :thumb_url
   validates :image, presence: true, on: :create, file_size: { less_than: 128.megabytes },
      size: { height: { min: 1500, max: 30000 }, width: { min: 150, max: 30000 }, ratio: { range: (0.1..5.0) }}

   before_validation :fill_in_uid
   before_validation :fill_in_digest, :fill_in_dimensions, :fill_in_url, :fill_in_thumb_url,
      if: -> { image.file && File.exist?(image.file.file) }

   def fill_in_dimensions
      self.height = image.height
      self.width = image.width
   end

   # callbacks
   def fill_in_digest
      if changed.include?("image")
         blob = image.respond_to?(:file) ? IO.read(image.file.file) : image
         self.digest = blob ? Digest::SHA2.hexdigest(blob) : ""
      end
   end

   def fill_in_uid
      self.uid ||= SecureRandom.uuid
   end

   def fill_in_url
      if changed.include?("image")
         self.url = File.join *[image.asset_host.to_s, image.store_dir, image.filename]
      end
   end

   def fill_in_thumb_url
      self.thumb_url = File.join *[image.asset_host.to_s, image.store_dir, "thumb_" + image.filename]
   end

   def attitude_to= value
      imageable_name = value&.sub(/\(.*/, '')
      pos_at = value&.sub(/.*\(/, '')

      attitudes.new(imageable_name: imageable_name, pos_at: pos_at) if imageable_name.present?
   end
end
