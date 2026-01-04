class ResourcesController < ApplicationController
   before_action :set_resources, only: %i(index)
   before_action :set_resource, only: %i(show)

   include CoreFeatures

   # GET /resources.json
   # GET /resources
   def index
      respond_to do |format|
         format.html do
            render :index,
               locals: {
                  resources: objects.range(@range).jsonize(context),
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

   # GET /resources/:uid.json
   # GET /resources/:uid
   def show
      respond_to do |format|
         format.html do
            render :show,
               locals: {
                  resource: object.jsonize(context),
                  cloud: @calendary_cloud.jsonize
               }
         end
         format.json do
            render json: object.jsonize(context)
         end
      end
   end

   protected

   def model_name
      "Resource"
   end

   def object_json
      object.jsonize(only: %w(id abbreviation title description text ))
   end

   def set_resources
      objects
   end

   def objects
      @resources ||= model.all.with_title(context)
   end

   def set_resource
      object
   end

   def object
      @resource ||=
         %w(with_title with_description).reduce(model) do |q, method|
            q.respond_to?(method) ? q.send(method, context) : q
         end.by_uno(params[:uno]).first || raise(::ActiveRecord::RecordNotFound.new(params[:uid]))
   end
end
