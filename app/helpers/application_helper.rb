module ApplicationHelper
 # a list of document partial templates to try to render for #render_document_partial
  #
  # (NOTE: I suspect #document_partial_name, #render_document_partial and #document_partial_path_templates 
  # should be more succinctly refactored in the future)
  def document_partial_path_templates
    # first, the legacy template names for backwards compatbility
    # followed by the new, inheritable style
    # finally, a controller-specific path for non-catalog subclasses
    @partial_path_templates ||= ["%2$s/%1$s", "%s_%s", "%s_default", "catalog/%s_%s", "catalog/%s_default"]
  end
  
end
