module JavascriptHelper
  def jquery_include_tag
    if RAILS_ENV == 'development'
      javascript_include_tag 'jquery'
    else
      javascript_include_tag 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js'
    end
  end
  
  def jquery_ui_include_tag
    if RAILS_ENV == 'development'
      javascript_include_tag 'jquery-ui'
    else
      javascript_include_tag 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.6/jquery-ui.min.js'
    end
  end
  
  def add_javascript(options={})
    content_for :javascripts do 
      if options[:src]
        javascript_include_tag(options[:src])
      elsif options[:partial]
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