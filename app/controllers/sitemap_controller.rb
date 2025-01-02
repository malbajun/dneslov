# app/controllers/sitemap_controller.rb
class SitemapController < ApplicationController
   layout nil

   def index
      respond_to do |format|
         format.xml do
            render :index, type: :builder, locals: { count: 3, folder: SitemapGenerator::Sitemap.public_path }
         end
      end
   end
end
