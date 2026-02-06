class Tag < ApplicationRecord
   extend Informatible
   include WithTitles
   include WithDescriptions
   include WithAppellations
   include ByToken

   has_many :taggables
   belongs_to :tag_kind, primary_key: :key, foreign_key: :kind, class_name: :Subject

   scope :by_query, -> text do
      left_outer_joins(:descriptions, :titles, :appellations).
         where("unaccent(titles_tags.text) ~* unaccent(?)", "\\m#{text}.*").or(
         where("unaccent(descriptions.text) ~* unaccent(?)", "\\m#{text}.*").or(
         where("unaccent(appellations_tags.text) ~* unaccent(?)", "\\m#{text}.*")))
   end
   singleton_class.send(:alias_method, :by_q, :by_query)

   scope :by_id, ->(id) { where(id: id.to_s.strip) }

   # by unique universal numbering object by id or appellation
   scope :by_uno, ->(uno) do
      case uno.to_s
      when /^\s*$/
         none
      when /^\s*\d+\s*$/
         by_id(uno)
      else
         by_appellation(uno)
      end
   end

#   scope :sec_language, ->(l, context = {}) do
#      language_code =
#         Subject.
#         where(kind_code: "Language").
#         joins(:appellations).
#         where(descriptions: { text: l}).first&.key || l
#      self.instance_variable_set("@language_code", language_code)
#
#      self
#   end
#
#   scope :sec_alphabeth, ->(a, context = {}) do
#      alphabeth_code =
#         Subject.
#         where(kind_code: "Alphabeth").
#         joins(:appellations).
#         where(descriptions: { text: a}).first&.key || a
#      self.instance_variable_set("@alphabeth_code", alphabeth_code)
#
#      self
#   end

   scope :by_language, ->(l) do
      joins(:descriptions, :titles, :appellations).
         where("unaccent(titles_tags.alphabeth_code) ~* ?", l).or(
         where("unaccent(descriptions.text) ~* ?", l).or(
         where("unaccent(appellations_tags.text) ~* ?", l)))
   end

   scope :by_alphabeth, ->(a) do
      joins(:descriptions, :titles, :appellations).
         where("unaccent(titles_tags.alphabeth_code) ~* ?", a).or(
         where("unaccent(descriptions.text) ~* ?", a).or(
         where("unaccent(appellations_tags.text) ~* ?", a)))
   end

   # required for short list
   scope :with_key, -> _ do
      selector = [ "descriptions.#{primary_key} AS _key" ]

      select(selector).group('_key').reorder("_key")
   end

   scope :with_value, -> context do
      selector = [ "descriptions.text AS _value" ]

      joins(:appellations).select(selector).group('_value').reorder("_value")
   end

   scope :with_kind_title, -> context do
      this = table.table_alias || table.name
      language_codes = context[:language] ? [context[:language]] : context[:text_languages]
      alphabeth_codes = context[:alphabeth] ? [context[:alphabeth]] : context[:text_alphabeths] || Languageble.alphabeth_list_for(language_codes)
      /`(?<method>(?:with_(?<rela>\w+)|[^']*))'/ =~ caller.grep(/delegation/)[1]
      as = context[:as] || model.reflections[rela]&.name || rela
      selector = self.select_values.dup
      selector << "#{this}.*" if selector.empty?
      selector << "#{as}_kind_titles.text AS _kind_title"

      join = "LEFT OUTER JOIN subjects AS #{as}_kinds
                           ON #{as}_kinds.kind_code = 'TagKind'
                          AND #{as}_kinds.key = #{this}.kind
              LEFT OUTER JOIN descriptions AS #{as}_kind_titles
                           ON #{as}_kind_titles.describable_id = #{as}_kinds.id
                          AND #{as}_kind_titles.describable_type = 'Subject'
                          AND #{as}_kind_titles.language_code IN ('#{language_codes.join("', '")}')
                          AND #{as}_kind_titles.alphabeth_code IN ('#{alphabeth_codes.join("', '")}')"

      joins(join).select(selector).group(:id, "#{as}_kind_titles.text")
   end

   validates_presence_of :appellations, :kind
end
