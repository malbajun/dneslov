class RitesController < ApplicationController
   before_action :set_rites, only: %i(index)
   before_action :set_rite, only: %i(show)

   include CoreFeatures

   # GET /rites.json
   # GET /rites
   def index
      respond_to do |format|
         format.html do
            render :index,
               locals: {
                  rites: objects.range(@range).jsonize(context),
                  total: objects.total_size,
                  range: @range,
                  cloud: @calendary_cloud.jsonize
               }
         end
         format.json do
            render json: objects.range(@range).jsonize(context)
         end
      end
   end

   # GET /rites/:uid.json
   # GET /rites/:uid
   def show
      respond_to do |format|
         format.html do
            render :show,
               locals: {
                  rite: object_json,
                  cloud: @calendary_cloud.jsonize
               }
         end
         format.json do
            render json: object_json
         end
      end
   end

   protected

   def model_name
      "Rite"
   end

   def object_json
      object.jsonize(only: %w(id abbreviation title description text))
   end

   def set_rites
      objects
   end

   def objects
      @rites ||= model.all.with_title(context)
   end

   def set_rite
      object
   end

   def object
      @rite ||=
         %w(with_title with_description).reduce(model) do |q, method|
            q.respond_to?(method) ? q.send(method, context) : q
         end.by_uno(params[:uno]).first || raise(::ActiveRecord::RecordNotFound.new(params[:uid]))
   end
end
