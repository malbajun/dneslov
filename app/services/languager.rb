class Languager
   attr_reader :language, :alphabeth

   LA = {
      "ЛА" => {
         upcase: false,
         table: {}
      },
      "РА" => {
         upcase: false,
         table: {}
      },
      "ДР" => {
         upcase: false,
         table: {}
      },
      "СС" => {
         upcase: false,
         table: {}
      },
      "ЦС" => {
         upcase: false,
         table: {}
      },
      "ДГ" => {
         upcase: false,
         table: {
      	      /^ϊ/ => 'ἰ',
      	      /^ϋ/ => 'ὐ',
      	      /^ά/ => 'ἀ',
      	      /^έ/ => 'ἐ',
      	      /^ή/ => 'ἠ',
      	      /^ί/ => 'ἰ',
      	      /^ΰ/ => 'ὐ',
      	      /^ό/ => 'ὀ',
      	      /^ύ/ => 'ὐ',
      	      /^ώ/ => 'ὠ',
      	      'ϊ' => 'ι',
      	      'ϋ' => 'υ',
      	      'ά' => 'ά',
      	      'έ' => 'έ',
      	      'ή' => 'ή',
      	      'ί' => 'ί',
      	      'ΰ' => 'ύ',
      	      'ό' => 'ό',
      	      'ύ' => 'ύ',
      	      'ώ' => 'ώ',
         }
      }
   }

   def initialize language: nil, alphabeth: nil
      @language = language || raise
      @alphabeth = alphabeth || raise
   end

   def name_letter_fix
      Name.transaction do
         rela = Name.where(language_code: language, alphabeth_code: alphabeth)

         rela.update_all("text = lower(text)") unless LA[:upcase]
         ids =
            rela.reduce([{},{}]) do |ids, name|
               text =
                  LA[alphabeth][:table].reduce(name.text) do |text_in, (re, val)|
                     text_in.gsub(re, val)
                  end

               if text != name.text
                  if rela.where(text: text).size > 0
                     [ids[0], ids[1].merge(name.id => text)]
                  else
                     [ids[0].merge(name.id => text), ids[1]]
                  end
               else
                  ids
               end
            end

          rela.where(id: ids[0].keys).find_each do |name|
             name.update_attribute(:text, ids[0][name.id])
          end
          rela.where(id: ids[1].keys).find_each do |name| 
             Rails.logger.error("Dupilcated name '#{name.text}' for language: #{language} and #{alphabeth}")
          end
      end
      Rails.logger.info("Letters for language #{language} and #{alphabeth} were fixed")
   end
end
