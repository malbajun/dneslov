class Admin::ScriptaController < Admin::CommonController
   protected

   def index_with_list
      %w(with_locale_names with_target_events with_resource with_ref_titles with_bind_kind_name by_root)
   end

   def permitted_params
      params.require(:scriptum).permit(
         :id, :language_code, :alphabeth_code, :title, :text, :description,
         :type, :author, :tone, :resource_id, :root_id, :bind_kind_name, :bond_to_id, :prosomeion_id,
         target_events_attributes: %i(id event_id kind _destroy))
   end
end
