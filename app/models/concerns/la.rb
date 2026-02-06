module La
   def apply_la this, context, &block
      language_codes = [this.instance_variable_get("@language_code"),
         context[:language], context[:text_languages], []]
      alphabeth_codes = [this.instance_variable_get("@alphabeth_code"),
         context[:alphabeth], context[:text_alphabeths], Languageble.alphabeth_list_for(language_codes)]
      (l, a) = [language_codes, alphabeth_codes].transpose.reject {|(l,a)| l.blank? && a.blank? }.first
      las = {language_code: l, alphabeth_code: a}.map {|x, y| y ? [x, [y].flatten.compact.join("', '")] : nil }.compact
 
      las.map(&block)
   end
end
