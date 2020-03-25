# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def set_content_for(name, content = nil, &block)
    # clears out the existing content_for so that its set rather than appended to
    ivar = "@content_for_#{name}"
    instance_variable_set(ivar, nil)
    content_for(name, content, &block)
  end

  def super_title(text, options = {})
    options.symbolize_keys!
    set_content_for :super_title, text
  end

  def title(text, options = {})
    options.symbolize_keys!

    set_content_for :title, strip_tags(text)
    unless options[:body] == false
      set_content_for :precolumn, content_tag(:h1, text)
    end
  end

  def description(text)
    set_content_for :description, strip_tags(text)
  end

  def sidebar(text)
    set_content_for :sidebar, text
  end

  def feed_autodiscovery(feed_url, title = 'RSS', options = {})
    link_html_options = {:rel => 'alternate', :type => 'application/rss+xml', :title => title, :href => feed_url, :class => 'subscription_feed'}

    if options[:search_conditions]
      link_html_options[:'data-search-conditions'] = options[:search_conditions].to_json
      entry_search = Entry.search_klass.new(:conditions => options[:search_conditions])
      link_html_options[:'data-public-inspection-subscription-supported'] = entry_search.public_inspection_search_possible?
    end

    if options[:subscription_default]
      link_html_options[:'data-default-search-type'] = options[:subscription_default]
    end

    content_for :feeds, tag(:link, link_html_options)
  end

  def pluralize_without_count(count, noun, text = nil)
    count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
  end
end
