class Resource < ApplicationRecord
   extend TotalSize
   extend DefaultKey
   include DistinctBy
   include WithTitles
   include WithDescriptions
   include ByQuery

   has_many :links, validate: true, inverse_of: :resource
   has_many :resource_markups, dependent: :delete_all
   has_many :scripta, validate: true, through: :resource_markups, inverse_of: :resource

   scope :unassigned, ->() do
      where.not(id: Link.resourced.select(:resource_id))
   end

   scope :by_uid, ->(uid) { where(uid: uid) }
   scope :by_id, ->(id) { where(id: id) }

   # title with or without event
   #scope :by_default_or_specific_title, ->(title) do
   scope :by_query_token, ->(title) do
      sub_m = self.by_title(title)

      joins(sub_m.joins_values).merge(sub_m.reorder("")).distinct
   end

   # by universal numbering object: by id, or by title
   scope :by_uno, ->(uno) do
      case uno
      when /^\s*$/
         none
      when /^\d+$/
         by_id(uno)
      when /^.+-.+-.+-.+-.+|[a-f0-9]{32}$/
         by_uid(uno)
      else
         by_query_token(uno)
      end
   end

   default_scope { order(updated_at: :desc) }

   validates_presence_of :resource, :uid
   validates_uniqueness_of :digest
   validates_uniqueness_of :uri

   before_validation :fill_in_uid, :fill_in_digest, :fill_in_uri

   # scopes
   # required for autocomplete list
   scope :with_key, -> _ do
      selector = ['resources.id AS _key']

      select(selector).group('_key').reorder("_key")
   end

   scope :with_value, -> context do
      #TODO add search over names
      selector = ['descriptions.text AS _value']

      joins(:titles).select(selector).group('_value').reorder("_value")
   end

   # callbacks
   def fill_in_digest
      if changed.include?("resource")
         blob = resource.respond_to?(:file) ? IO.read(resource.file.file) : resource
         self.digest = blob ? Digest::SHA2.hexdigest(blob) : ""
      end
   end

   def fill_in_uid
      self.uid ||= SecureRandom.uuid
   end

   def fill_in_uri
      if changed.include?("resource")
         self.uri =
            if resource.respond_to?(:store_dir)
               File.join *["", resource.store_dir, resource.filename]
            elsif resource
               "blob:" + URI::Parser.new.escape(resource)
            end
      end
   end

   def language= value
      self.title_language = value
      self.description_language = value
   end

   def alphabeth= value
      self.title_alphabeth = value
      self.description_alphabeth = value
   end
end
