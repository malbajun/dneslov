class Admin::RitesController < Admin::CommonController
   protected

   def index_with_list
      %w(by_root with_titles with_descriptions with_root_rite with_bond_to_rite with_locale_names with_bind_kind_rite)
   end

   def permitted_params
      params.require(:rite).permit(
         :id, :abbreviation, :text, :language_code, :alphabeth_code, :root_id, :bond_to_id, :bind_kind_rite,
         titles_attributes: %i(id text language_code alphabeth_code _destroy),
         descriptions_attributes: %i(id text language_code alphabeth_code _destroy))
   end
end
