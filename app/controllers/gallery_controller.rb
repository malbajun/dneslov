class GalleryController < ApplicationController
   before_action :set_memory, only: %i(show index)
   before_action :set_event, only: %i(index), if: -> { params[:event].present? }
   before_action :set_images, only: %i(index)
   before_action :set_image, only: %i(show)

   include CoreFeatures

   # GET /:slug/gallery.json
   # GET /:slug/gallery
   def index
      respond_to do |format|
         format.html do
            render :index,
               locals: {
                  gallery: {
                     images: @images.jsonize,
                     attitude_to: attitude_to,
                     slug: memory.slug.text,
                     event_id: @event&.id
                  },
                  cloud: @calendary_cloud.jsonize
               }
         end
         format.json do
            render json: {
               images: @images.jsonize,
               attitude_to: attitude_to,
               slug: memory.slug.text,
               event_id: @event&.id
            }
         end
      end
   end

   # GET /:slug/gallery/:uid.json
   # GET /:slug/gallery/:uid
   # GET /:slug/:event_id/gallery/:uid.json
   # GET /:slug/:event_id/gallery/:uid
   def show
      respond_to do |format|
         format.html do
            render :show,
               locals: {
                  image: {
                     picture: @image.jsonize,
                     context: context,
                     attitude_to: attitude_to,
                     slug: memory.slug.text,
                     event_id: @event&.id
                  },
                  cloud: @calendary_cloud.jsonize
               }
         end
         format.json do
            render json: {
               picture: @image.jsonize,
               context: context,
               attitude_to: attitude_to,
               slug: memory.slug.text,
               event_id: @event&.id
            }
         end
      end
   end

   protected

   def memory
      @event&.memory || @memory
   end

   def attituded
      @event || @memory
   end

   def attitude_to
      if @event
         "#{@event.memory.short_name}##{@event.id}"
      elsif @memory
         @memory.short_name
      end
   end

   def set_images
      @images = attituded.all_pictures
                         .with_titles(context)
                         .with_descriptions(context)
   end

   def set_image
      @image =
         attituded.all_pictures
         .with_titles(context)
         .with_descriptions(context)
         .by_uid(params[:uid])
         .first || raise(::ActiveRecord::RecordNotFound.new(params[:uid]))
   end

   def set_event
      @events = @memory.events
                       .memoed_for(@calendary_slugs)

      @event ||= @events.by_event_code(params[:event]).first || raise(ActiveRecord::RecordNotFound)
   end

   def set_picture
      @picture ||= Picture.by_uid(params[:uid]).first || raise(ActiveRecord::RecordNotFound)
   end
end
