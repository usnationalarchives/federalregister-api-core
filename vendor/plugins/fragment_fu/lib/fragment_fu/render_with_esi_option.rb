module FragmentFu
  module RenderWithEsi
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :render, :esi_option
      end
    end

    module InstanceMethods
      def render_with_esi_option(options = {}, old_local_assigns = {}, &block)
        if options[:esi]
          render_esi(options)
        else
          render_without_esi_option(options, old_local_assigns, &block)
        end
      end

      def render_esi(options)
        url = options[:esi]
        query = (url.is_a?(Hash) ? controller.url_for(url.merge({:only_path => true})).gsub(/.*\?/,'') : url)
        %Q{<esi:include src="#{query}" max-age="#{options[:ttl].to_i || 0}"/>} 
      end
    end

 end
end