module Html5Helper
  HTML5_TAGS = %w(article aside canvas date details figcaption figure footer header hgroup mark menu nav section summary time )
  
  def html5_tag(tag_name, *args, &block)
    options = args.extract_options!
    options.symbolize_keys!
    
    if block_given?
      content = capture(&block)
      concat(wrap_html5_content(tag_name, content, options))
    else
      content = args.join
      wrap_html5_content(tag_name, content, options)
    end
  end
  
  def wrap_html5_content(tag_name, content, options)
    html = content_tag(tag_name, options.except(:id, :class)) do
      options[:class] = add_class(options[:class], tag_name)
      content_tag(:div, content, options)
    end
  end
  
  HTML5_TAGS.each do |tag_name|
    eval <<-RUBY
      def #{tag_name}_tag(*args, &proc)
        
        if block_given?
          html5_tag(:#{tag_name}, *args, &proc)
        else
          html5_tag(:#{tag_name}, *args)
        end
      end
    RUBY
  end
  
  private
  
  def add_class(original, to_add)
    if original.present?
      "#{to_add} #{original}"
    else
      to_add
    end
  end
end