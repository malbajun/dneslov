class Api::V1::CalendariesController < Api::CommonController
   def objects
      @objects ||=
         Calendary.licit_with(params[:c])
                  .with_title(languages)
                  .with_description(languages)
                  .with_url
                  .with_slug_text
                  .group("calendaries.id")
                  .distinct_by('_slug')
   end
end
