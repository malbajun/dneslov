module CoreFeatures
   include ActiveSupport::Concern
   class OutOfRangeError < StandardError; end

   def self.included k
      k.class_eval do
         prepend_before_action :set_memory, only: %i(index show), if: ->(x) { @slug&.sluggable_type == "Memory" }
         prepend_before_action :set_slug, only: %i(index show), if: -> { params[:slug].present? }
         prepend_before_action :set_calendary_slugs, only: %i(index show)
         prepend_before_action :set_date, :set_calendary_cloud, :set_julian, :set_languages
         prepend_before_action :default, only: %i(index show)
         before_action :parse_range, only: %i(index show), if: ->(x) { total }

         rescue_from Exception, with: :render_default_error
         # NOTE https://stackoverflow.com/a/48744792/446267
         rescue_from ActionController::UnknownFormat, with: :render_default_error
         rescue_from ActiveRecord::RecordNotFound, with: :render_not_exist_error
         rescue_from CoreFeatures::OutOfRangeError, with: :out_of_range

         has_scope :d, only: %i(index show) do |_, scope, value|
            if /(?<julian>[ню])?(?<date>[0-9\-\.]+)/ =~ value
               scope.d( date, julian != "н" )
            else
               scope
            end
         end
         has_scope :c, only: %i(index show)
      end
   end

   def context
      @_context ||= {
         locales: @locales,
         locale: @locale,
         calendary_slugs: calendary_slugs,
         text_languages: @text_languages,
         service_languages: @service_languages,
         language: @language,
         alphabeth: @alphabeth,
      }
   end

   # lazy property
   def _date
      # TODO add detection time zone from request
      @_date ||= (
         date = Time.now + church_time_gap
         is_julian_calendar? && date - julian_gap || date )
   end

   def is_julian_calendar?
      params[ :d ]&.[](0) != 'н'
   end

   def church_time_gap
      9.hours
   end

   def julian_gap
      #TODO remove fixed julian gap
      13.days
   end

   def calendary_slugs
      @calendary_slugs ||=
         if params[:c].present?
            Slug.for_calendary.where(text: params[:c].split(",") ).pluck(:text)
         else
            default_calendary_slugs
         end
   end

   def default_calendary_slugs
      #TODO make automatic detection of calendary depended on the IP and country of request
      ['днес','рпц']
   end

   def default
      if !(params[ :c ] || params[ :d ] || params[ :q ])
         params[ :d ] ||= "#{is_julian_calendar? && 'ю' || "н"}#{_date.strftime("%d-%m-%Y")}"
         params[ :c ] ||= default_calendary_slugs.join(",")
      end

      @range = (0..24)
   end

   def set_languages
      # NOTE the default values
      @locales ||= I18n.available_locales
      @locale ||= I18n.locale
      @text_languages ||= %w(ру)
      @service_languages ||= %w(цс)
      @language ||= "ру"
      @alphabeth ||= "РО"
   end

   def set_date
      @date ||=
         if /(?<julian>[ню])?(?<date>[0-9\-\.]+)/ =~ params[ :d ]
            Date.parse(date)
         end
   end

   def set_calendary_slugs
      calendary_slugs
   end

   def set_calendary_cloud
      @calendary_cloud ||=
         Calendary.licit_with(params[ :c ])
                  .with_title(context)
                  .with_description(context)
                  .with_url
                  .with_slug_text
                  .group("calendaries.id")
                  .distinct_by('_slug')
   end

   def set_julian
      @julian ||= is_julian_calendar?
   end

   def set_slug
      @slug =
         if params[:slug]
            Slug.where(text: params[:slug]).first || raise(ActiveRecord::RecordNotFound)
         end
   end

   def per
      (params[:per] || 25).to_i
   end

   def page
      (params[:page] || params[:p] || 1).to_i
   end

   def parse_range
      @range =
         if /(?<b>[0-9]+)-(?<e>[0-9]+)/ =~ request.headers["Range"]
            (b.to_i..e.to_i - 1)
         else
            ((page - 1) * per..(page - 1) * per + per - 1)
         end

      raise CoreFeatures::OutOfRangeError if total > 0 && @range.begin >= total || @range.end < @range.begin
   end

   def total
      @total ||=
         %i(total_size total_count count).reduce(nil) do |count, method|
            objects.respond_to?(method) && !count ? objects.send(method) : count
         end || raise if objects
   end

   def model_name
      "Memory"
   end

   def set_memory
      @memorys ||=
         %w(with_short_name with_scripta with_memoes with_names with_coverings with_orders
            with_bond_memories with_icon with_title with_description with_slug_text).reduce(Memory.unscoped) do |q, method|
            q.respond_to?(method) ? q.send(method, context) : q
         end.with_pure_links

      @memory ||= @memorys.find_by_slug(@slug.text) || raise( ActiveRecord::RecordNotFound )
   end

   def out_of_range _e
      render json: {}, status: 416
   end

   def objects
      @memoes
   end
end
