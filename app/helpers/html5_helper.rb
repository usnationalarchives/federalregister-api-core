module Html5Helper
  BLOCK_HTML5_TAGS = %w(article aside canvas details figcaption figure footer header hgroup menu nav section summary)
  INLINE_HTML5_TAGS = %w(date mark time)
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
  
  (BLOCK_HTML5_TAGS + INLINE_HTML5_TAGS).each do |tag_name|
    eval <<-RUBY
      def #{tag_name}_tag(*args, &proc)
        html5_tag(:#{tag_name}, *args, &proc)
      end
    RUBY
  end
  
  private
  
  def wrap_html5_content(tag_name, content, options)
    html_tag_name = options.delete(:as) || INLINE_HTML5_TAGS.include?(tag_name.to_s) ? 'span' : 'div'
    
    html = content_tag(tag_name, options.except(:id, :class)) do
      options[:class] = add_class(options[:class], tag_name)
      content_tag(html_tag_name, content, options)
    end
  end
  
  def add_class(original, to_add)
    if original.present?
      "#{to_add} #{original}"
    else
      to_add
    end
  end
end