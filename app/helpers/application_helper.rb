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

  def render_media_partial doc, locals = {}
    format = document_partial_name(doc)
    mime = doc.get(:mime_type_t).to_s.parameterize("_")

    partial_paths = ["%2$s/_media_partials/%1$s", "%2$s/_media_partials/default"]

    partial_paths.each do |str|
      begin
        return render :partial => (str % [mime, format]), :locals=>locals.merge({:document=>doc})  
      rescue ActionView::MissingTemplate
        nil
      end
    end

    return
  end
end
