module FragmentFu
  module InvalidationHelper
    def invalidate_and_redirect_to(options)
      unless options[:redirect]
        raise(ArgumentError, "Requires :to_url and :invalidate_url as parameters") 
      end
      #If you dont set an invalidate hash, assume you're invalidating what you are redirecting to
      options[:invalidate] ||= options[:redirect] 

      to_url = options[:redirect].is_a?(Hash) ? url_for(options[:redirect]) : options[:redirect]
      headers["Location"] = to_url
      headers["Surrogate-Control"] = "ESI-INV 1.0" #TODO confirm this header is correct
      invalidation = invalidate_fragment(self, options[:invalidate])
      render :status => "303 See Other", 
        :text => "<html><body>#{invalidation}\nYou are being <a href=\"#{to_url}\">redirected</a>.</body></html>"
    end

    def invalidate_fragment(controller, invalidate, removal_ttl = 0, debug_message = "")
      invalidate_url = invalidate.is_a?(Hash) ? controller.url_for(invalidate) : invalidate
      invalidate_text = <<-EOF
         <esi:invalidate output="no">
           <?xml version="1.0"?>
           <!DOCTYPE INVALIDATION SYSTEM "internal:///WCSinvalidation.dtd">
           <INVALIDATION VERSION="WCS-1.1">
             <OBJECT>
               <BASICSELECTOR URI="#{invalidate_url}"/>
               <ACTION REMOVALTTL="#{removal_ttl}"/>
               <INFO VALUE="#{debug_message}"/>
             </OBJECT>
           </INVALIDATION>
         </esi:invalidate>
        EOF
      invalidate_text
    end
 
  end
end