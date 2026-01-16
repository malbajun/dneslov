#licit[boolean]         - действительный календарь (не в разработке)
class Calendary < ActiveRecord::Base
   extend TotalSize
   include DistinctBy
   include Languageble
   include WithLocaleNames
   include WithDescriptions
   include WithTitles
   include WithLinks
   include ByToken

   JSON_SCHEMA = Rails.root.join('config', 'schemas', 'calendary.json')
   JSONIZE_ATTRS = {
      meta: ->(this) { this.meta.to_json },
   }

   attr_defaults meta: "{}"

   belongs_to :place, optional: true

   has_many :titles, as: :describable, dependent: :delete_all, class_name: :Appellation
   has_many :wikies, as: :info, dependent: :delete_all, class_name: :WikiLink
   has_many :beings, as: :info, dependent: :delete_all, class_name: :BeingLink
   has_many :memos, dependent: :delete_all
   has_one :slug, as: :sluggable

   scope :licit, -> { where( licit: true ) }
   scope :licit_with, ->(c) do
      if c.blank?
         self.licit
      else
         self.left_outer_joins(:slug).licit.or(self.by_slugs(c))
      end
   end
   scope :described_as, -> name { joins( :descriptions ).where( descriptions: { text: name } ) }
   scope :by_slug, -> slug { joins( :slug ).where( slugs: { text: slug.split(",") } ) }
   scope :by_slugs, -> slugs do
      return self if slugs.blank?
      slugs = slugs.split(",") if slugs.is_a?(String)
      # TODO add correct sort by slugs pos
      select("calendaries.*, slugs.*")
       .from("slugs, calendaries")
       .where( "slugs.sluggable_id = calendaries.id
            AND slugs.sluggable_type = '#{model}'
            AND slugs.text IN (?)", [ slugs ].flatten)
       .reorder("slugs.text")
   end

   scope :by_uno, ->(uno) do
      case uno.to_s
      when /^\s*$/
         none
      when /^\d+$/
         by_id(uno)
      else
         by_slug(uno)
      end
   end

   scope :by_licit, ->(licit) { where(licit: licit) }
   scope :by_token, -> text do
      left_outer_joins( :slug, :descriptions, :titles ).
         where( "unaccent(calendaries.author_name) ~* unaccent(?)", "\\m#{text}.*" ).or(
         where( "unaccent(calendaries.council) ~* unaccent(?)", "\\m#{text}.*" ).or(
         where( "slugs.text ~* ?", "\\m#{text}.*" ).or(
         where( "unaccent(descriptions.text) ~* unaccent(?)", "\\m#{text}.*" ).or(
         where( "unaccent(titles_calendaries.text) ~* unaccent(?)", "\\m#{text}.*" )))))
   end
   singleton_class.send(:alias_method, :by_query, :by_token)

   scope :by_tokens, -> string_in do
      return self if string_in.blank?
      # TODO fix the correctness of the query
      klass = self.model_name.name.constantize
      or_rel_tokens = string_in.split(/\//).map do |or_token|
         # OR operation
         or_token.strip.split(/\s+/).reduce(nil) do |rel, and_token|
            # AND operation
            and_rel = klass.by_token(and_token)
            rel && rel.merge(and_rel) || and_rel ;end;end
      or_rel = or_rel_tokens.reduce { |sum_rel, rel| sum_rel.or(rel) }
      self.merge(or_rel).distinct
   end

   singleton_class.send(:alias_method, :t, :by_token)
   singleton_class.send(:alias_method, :q, :by_tokens)
   singleton_class.send(:alias_method, :l, :by_licit)

   # required for short list
   scope :with_key, -> _ do
      selector = ['calendaries.id AS _key']

      select(selector).group('_key') ;end

   scope :with_value, -> context do
      language_codes = [context[:text_languages]].flatten.compact
      alphabeth_codes = Languageble.alphabeth_list_for(language_codes)
      selector = [ 'descriptions.text AS _value' ]
      if self.select_values.dup.empty?
        selector.unshift( 'calendaries.*' )
      end

      if language_codes.any?
         lang_where = "AND descriptions.language_code IN ('#{language_codes.join("', '")}')"
      end

      if alphabeth_codes.any?
         alph_where = "AND descriptions.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"
      end

      join = "LEFT OUTER JOIN descriptions ON descriptions.describable_id = calendaries.id
                          AND descriptions.describable_type = '#{model}'
                          AND descriptions.type = 'Appellation'
                          #{lang_where} #{alph_where}"

      joins(join).select(selector.uniq).group('_value')
   end

   scope :with_url, -> do
      selector = 'links.url AS _url'

      left_outer_joins(:links).select(selector).group('_url')
   end

   scope :with_slug_text, -> do
      selector = self.select_values.dup
      if self.select_values.dup.empty?
         selector << 'calendaries.*'
      end

      selector << 'slugs.text AS _slug'

      left_outer_joins(:slug).group("slugs.text").select(selector)
   end

   scope :with_slug, -> do
      as = table.table_alias || table.name
      selector = self.select_values.dup
      selector << "#{as}.*" if selector.empty?
      selector << "jsonb_build_object('id', #{as}_slugs.id, 'text', #{as}_slugs.text) AS _slug"

      join = "LEFT OUTER JOIN slugs AS #{as}_slugs
                           ON #{as}_slugs.sluggable_id = calendaries.id
                          AND #{as}_slugs.sluggable_type = '#{model}'"

      joins(join).select(selector).group(:id, "#{as}_slugs.id", "#{as}_slugs.text")
   end

   singleton_class.send(:alias_method, :t, :by_token)
   accepts_nested_attributes_for :place, reject_if: :all_blank, allow_destroy: true
   accepts_nested_attributes_for :slug, reject_if: :all_blank, allow_destroy: true

   has_alphabeth
   validates :language_code, inclusion: { in: Languageble.language_list }
   validates :alphabeth_code, inclusion: { in: proc { |l| Languageble.alphabeth_list_for(l.language_code)}}
   validates :slug, :date, presence: true
   validates :place, associated: true
   validates_presence_of :titles
   validates :meta, json: { schema: JSON_SCHEMA }

   def default_title
      titles.first.text
   end

   def datetime_range
      @datetime_range ||=
         if /(\d*)\-(\d*)/ =~ date
            b = $1.blank? ? -Float::INFINITY : Date.new($1.to_i, 1, 1)
            e = $2.blank? ? Float::INFINITY : Date.new($2.to_i, 1, 1)
            (b..e)
         elsif date
            t = Date.new(date.to_i, 1, 1)
            (t..t)
         end
   end

   def datetime
      if datetime_range.begin != -Float::INFINITY
         datetime_range.begin
      elsif datetime_range.end != Float::INFINITY
         datetime_range.end
      end
   end
end
