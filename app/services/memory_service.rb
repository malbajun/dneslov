class MemoryService
  attr_reader :description, :description_from

   def initialize description: nil, description_from: nil
      @description = description
      @description_from = description_from
   end

   def memories
      @memories ||= description ? Memory.left_outer_joins(:short_names).by_tale(description).or(Memory.by_short_name(description)).distinct : Memory.none
   end

   def memories_from
      @memories_from ||= description_from ? Memory.by_tale(description_from) : Memory.none
   end

   def named_ids
      @named_ids ||= memories.select {|m| m.short_names.any? }.map(&:id)
   end

   def main_id
      @main_id ||=
         case named_ids.size
         when 0
            m = memories.first
            m.short_names = m.tales.map {|t| ShortName.new(text: t.text, language_code: t.language_code, alphabeth_code: t.alphabeth_code) }
            text = m.tales.where(language_code: "ру", alphabeth_code: "РО").first.text
            m.slug = Slug.new(text: text.downcase.gsub(/[^а-яё]+/, '-'))
            nomen =
               Nomen.where(text: text, language_code: "ру", alphabeth_code: "РО").first ||
               Nomen.create(text: text, language_code: "ру", alphabeth_code: "РО")
            m.memory_names << MemoryName.new(nomen_id: nomen.id, state_code: "наречёное")
            m.save!(validate: false)

            m.id
         when 1
            named_ids.first
         end
   end

   # actors
   def merge
      Memory.transaction do
         ids = (memories.map(&:id) | memories_from.map(&:id)) - [main_id]

         Event.where(place_id: ids).update!(place_id: main_id)
         # seems was broken
         # CantoMemory.where(memory_id: ids).update!(memory_id: main_id)
         Covering.where(memory_id: ids).update!(memory_id: main_id)
         EventRole.where(memory_id: ids).update!(memory_id: main_id)
         MemoryBind.where(memory_id: ids).update!(memory_id: main_id)
         MemoryName.where(memory_id: ids).update!(memory_id: main_id)
         # info_type
         Link.where(info_id: ids, info_type: "Memory").update!(info_id: main_id)
         Service.where(info_id: ids, info_type: "Memory").update!(info_id: main_id)
         # audioable_type
         AudioAttitude.where(audioable_id: ids, audioable_type: "Memory").update!(audioable_id: main_id)
         # imageable_type
         ImageAttitude.where(imageable_id: ids, imageable_type: "Memory").update!(imageable_id: main_id)
         # roundelable_type
         Roundel.where(roundelable_id: ids, roundelable_type: "Memory").update!(roundelable_id: main_id)
         # scribable_type
         ScriptumScribable.where(scribable_id: ids, scribable_type: "Memory").update!(scribable_id: main_id)
         # sluggable_type
         Slug.where(sluggable_id: ids, sluggable_type: "Memory").update!(sluggable_id: main_id)
         # tokenable_type
         Token.where(tokenable_id: ids, tokenable_type: "Memory").update!(tokenable_id: main_id)
         # bindable_type
         UserName.where(bindable_id: ids, bindable_type: "Memory").update!(bindable_id: main_id)
         # describable_type
         # full merge
         Description.where(describable_id: ids, describable_type: "Memory").find_each do |d|
            parent = Description.where(language_code: d.language_code, alphabeth_code: d.alphabeth_code, describable_id: main_id, describable_type: "Memory").first
            if parent
               if /#{d.text}/ !~ parent.text
                  parent.update_attribute(:text, parent.text + " " + d.text)
               end

               d.destroy
            else
               d.update_attribute(:describable_id, main_id)
            end
         end

         # drop other
         Memory.where(id: ids).delete_all
      end if main_id
   end
end 
