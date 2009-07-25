module JavascriptHelper
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