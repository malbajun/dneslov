class Api::CommonController < ApplicationController
   include ::Tiun::CoreHelper
   include ::Tiun::Base

   before_action :set_languages

   def set_languages
      # NOTE the default values
      @languages ||= %i(ру)
      @service_languages ||= %i(цс)
      @interface_languages ||= %i(ру)
   end

   def context
      @_context ||= {
         except: supplement_names,
         locales: locales,
         languages: @languages,
         interface_language: @interface_language,
         service_languages: @service_languages
      }
   end
end
