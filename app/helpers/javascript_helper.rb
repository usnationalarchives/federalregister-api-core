module JavascriptHelper
  # be sure to update the Varnish vcl_hash method to hash based on the presence of this cookie
  #   for whatever pages you're adding this to
  def js_known_to_be_enabled?
    request.cookies["javascript_enabled"] == "1"
  end
  
  def jquery_include_tag
    # if RAILS_ENV == 'development'
      javascript_include_tag 'admin/jquery'
    # else
    #   javascript_include_tag 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js'
    # end
  end
  
  def jquery_ui_include_tag
    # if RAILS_ENV == 'development'
      javascript_include_tag 'admin/jquery-ui'
    # else
    #   javascript_include_tag 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.6/jquery-ui.min.js'
    # end
  end
  
  def add_javascript(options={})
    partial = options.delete(:partial) || nil
    content_for :javascripts do
      if options[:src]
        javascript_include_tag(options.delete(:src), options)
      elsif partial
        render options
      else
        content = yield
        if content !~ /^\s*<script\b/
          javascript_tag(content)
        else
          content
        end
      end
    end
  end
end
