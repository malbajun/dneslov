# Picture class is keeping image resources info
require 'securerandom'

class Picture < ApplicationRecord
   attr_writer :language, :alphabeth, :description, :title

   include WithTitles
   include WithDescriptions

   mount_base64_uploader :image, ImageUploader
   process_in_background :image
   store_in_background :image

   has_many :attitudes, class_name: :ImageAttitude
   has_many :memories, as: :imageable, through: :attitudes, source: :imageable, source_type: :Memory
   has_many :events, as: :imageable, through: :attitudes, source: :imageable, source_type: :Event

   scope :by_language, ->(l) do
      joins(:titles, :descriptions).where(titles: { language_code: l}).and(where(descriptions: { language_code: l}))
   end

   scope :by_alphabeth, ->(a) do
      joins(:titles, :descriptions).where(titles: { alphabeth_code: a}).and(where(descriptions: { alphabeth_code: a}))
   end

   scope :by_memory, ->(m) do
      sub = m =~ /^\d+$/ ? Memory.where(id: m) : Memory.by_token(m)

      joins(:memories).merge(sub.reorder(""))
   end

   scope :by_event, ->(e) do
      if e.respond_to?(:arel)
         joins(:attitudes).where(image_attitudes: {imageable_type: "Event", imageable_id: e.select(:id) })
      else
         joins(:events).merge(Event.by_token(e).reorder(""))
      end
   end

   # by universal numbering object: by id, by slug, by short_name or by title
   scope :by_uno, ->(uno) do
      case uno
      when /^\s*$/
         none
      when /^\d+$/
         by_uid(uno)
      when /(.+)#(.+)/
         by_roundelable_name(uno)
      else
         by_title(uno)
      end
   end

   validates_presence_of :type, :uid, :image
   validates_uniqueness_of :digest, on: :create
   validates_uniqueness_of :uid, :url, :thumb_url
   validates :image, presence: true, on: :create, file_size: { less_than: 128.megabytes },
      size: { height: { min: 1500, max: 30000 }, width: { min: 150, max: 30000 }, ratio: { range: (0.1..5.0) }}

   before_validation :fill_in_title_description, :fill_in_uid
   before_validation :fill_in_digest, :fill_in_dimensions, :fill_in_url, :fill_in_thumb_url,
      if: -> { image.file && File.exist?(image.file.file) }

   def fill_in_dimensions
      self.height = image.height
      self.width = image.width
   end

   def fill_in_digest
      self.digest ||= Digest::SHA2.hexdigest(IO.read(image.file.file))
   end

   def fill_in_uid
      self.uid ||= SecureRandom.uuid
   end

   def fill_in_url
      self.url = File.join *[image.asset_host.to_s, image.store_dir, image.filename]
   end

   def fill_in_thumb_url
      self.thumb_url = File.join *[image.asset_host.to_s, image.store_dir, "thumb_" + image.filename]
   end

   def fill_in_title_description
      if @title
         if title = titles.where(language_code: @language, alphabeth_code: @alphabeth).first
            title.update_attribute(:text, @title)
         else
            titles << Title.new(text: @title, language_code: @language, alphabeth_code: @alphabeth)
         end
      end

      if @description
         if desc = descriptions.where(language_code: @language, alphabeth_code: @alphabeth).first
            desc.update_attribute(:text, @description)
         else
            descriptions << Description.new(text: @description, language_code: @language, alphabeth_code: @alphabeth)
         end
      end
   end

   # serialized
   def title
      @title ||= titles.where(language_code: language, alphabeth_code: alphabeth).first&.text
   end

   def description
      @description ||= descriptions.where(language_code: language, alphabeth_code: alphabeth).first&.text
   end

   def language
     @language ||= titles.first&.language_code || descriptions.first&.language_code
   end

   def alphabeth
      @alphabeth ||= titles.first&.alphabeth_code || descriptions.first&.language_code
   end

   def attitude_to= value
      imageable_name = value&.sub(/\(.*/, '')
      pos_at = value&.sub(/.*\(/, '')

      attitudes.new(imageable_name: imageable_name, pos_at: pos_at) if imageable_name.present?
   end
end
