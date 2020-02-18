module EsiHelper

  def render_esi(options)
    #NOTE: This method soureed from FragmentFu::RenderWithEsi#render_esi
    url = options[:esi]
    query = (url.is_a?(Hash) ? controller.url_for(url.merge({:only_path => true})).gsub(/.*\?/,'') : url)
    %Q{<esi:include src="#{query}" max-age="#{options[:ttl].to_i || 0}"/>}.html_safe
  end

end
