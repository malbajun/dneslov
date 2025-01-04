class Markup < ActiveRecord::Base
   extend TotalSize

   belongs_to :scriptum
   belongs_to :reading
   acts_as_list scope: :reading

   delegate :text, to: :scriptum

   scope :by_text, -> text do
      this = table.table_alias || table.name
      as = "by_text_#{this}"

      join = "LEFT JOIN scripta AS #{as}_scripta
                     ON #{as}_scripta.id = #{this}.scriptum_id"

      joins(join).where("#{as}_scripta.text ~* ?", text)
   end
end
