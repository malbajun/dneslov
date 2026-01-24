class Admin::NominaController < Admin::CommonController
   protected

   def index_with_list
      %w(by_root with_locale_names with_descriptions with_links with_root_name
         with_bond_to_name with_bind_kind_name)
   end

   def permitted_params
      params.require(:nomen)
         .permit(:text, :language_code, :alphabeth_code,
         :root_id, :bind_kind_name, :modifier, :bond_to_id, :rules, :kind,
         links_attributes: %i(id url language_code alphabeth_code type _destroy),
         descriptions_attributes: %i(id text language_code alphabeth_code _destroy))
   end
end
