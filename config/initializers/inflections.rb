# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
   inflect.singular /(.*)(oes|o)$/i, '\1o'
   inflect.singular /(.*)(ina|en)/i, '\1en'
   inflect.singular /(.*)(i|us)$/i, '\1us'
   inflect.plural /(.*)(o|oes)$/i, '\1oes'
   inflect.plural /(.*)(en|ina)$/i, '\1ina'
   inflect.plural /(.*)(us|i)$/i, '\1i'
#   inflect.plural /(.*)um$/i, '\1a'
#   inflect.singular /(.*)a/i, '\1um'
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
   inflect.irregular 'event', 'events'
   inflect.irregular 'audio', 'audios'
#   inflect.uncountable %w( fish sheep )
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end
