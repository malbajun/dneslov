class GalleryController < ApplicationController
   before_action :set_event, only: %i(index), if: -> { params[:event].present? }
   before_action :set_images, only: %i(index)
   before_action :set_image, only: %i(show)

   include CoreFeatures

   # GET /gallery.json
   # GET /gallery
   # GET /:slug/gallery.json
   # GET /:slug/gallery
   # GET /:slug/:event_id/gallery.json
   # GET /:slug/:event_id/gallery
   def index
      respond_to do |format|
         format.html do
            render :index,
               locals: {
                  attituded: attituded_json,
                  images: @images.ranged_with(@range).jsonize(context),
                  total: @images.total_size,
                  range: @range,
                  cloud: @calendary_cloud.jsonize
               }
         end
         format.json do
            render plain: attituded_json.merge({
               images: @images.ranged_with(@range).jsonize(context),
               total: @images.total_size,
               range: @range,
            }).to_json(context)
         end
      end
   end

   # GET /gallery/:uid.json
   # GET /gallery/:uid
   def show
      respond_to do |format|
         format.html do
            render :show,
               locals: {
                  image: image_json,
                  cloud: @calendary_cloud.jsonize
               }
         end
         format.json do
            render json: image_json
         end
      end
   end

   protected

   def object
      attituded
   end

   def memory
      @event&.memory || @memory
   end

   def attituded
      @event || @memory || Picture
   end

   def image_json
      @image.jsonize(only: %w(uid title description attitudes_to url type width height))
   end

   def attituded_json
      if attituded.is_a?(Class)
         {}
      else
         attituded.jsonize(only: %w(id gallery_title gallery_event attitude_to slug event_id))
      end
   end

   def set_images
      objects
   end

   def objects
      @images ||= attituded.all_pictures.with_title(context)
   end

   def set_image
      @image =
         %w(with_attitudes_to with_title with_description).reduce(attituded.all_pictures) do |q, method|
            q.respond_to?(method) ? q.send(method, context) : q
         end.by_uid(params[:uid]).first || raise(::ActiveRecord::RecordNotFound.new(params[:uid]))
   end

   def set_event
      @events =
         %w(with_attitude_to with_slug_text with_event_id with_gallery_title with_gallery_event memoed_for).reduce(@memory.events) do |q, method|
            q.respond_to?(method) ? q.send(method, context) : q
         end

      @event ||= @events.by_event_code(params[:event]).first || raise(ActiveRecord::RecordNotFound)
   end

   def set_memory
      @memorys ||=
         %w(with_attitude_to with_slug_text with_gallery_title with_short_name).reduce(Memory.unscoped) do |q, method|
            q.respond_to?(method) ? q.send(method, context) : q
         end

      @memory ||= @memorys.find_by_slug(@slug.text) || raise( ActiveRecord::RecordNotFound )
   end

   def set_picture
      @picture ||= Picture.by_uid(params[:uid]).first || raise(ActiveRecord::RecordNotFound)
   end
end
