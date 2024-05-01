class Admin::ReadingsController < Admin::CommonController
   protected

   def index_with_list
      %w(with_markups with_descriptions)
   end

   def permitted_params
      params.require(:reading).permit(
         :id, :year_date, :abbreviation, :kind,
         descriptions_attributes: %i(id text language_code alphabeth_code _destroy),
         markups_attributes: %i(id begin end position scriptum_id _destroy))
   end
end
