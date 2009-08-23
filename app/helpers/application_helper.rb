# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(text, options = {})
    options.symbolize_keys!
    
    content_for :title, text
    unless options[:body] == false
      content_for :precolumn, content_tag(:h1, text)
    end
  end
  
  def feed_autodiscovery(feed_url, title = 'RSS')
    content_for :feeds, content_tag(:link, nil, :rel => 'alternate', :type => 'application/rss+xml', :title => title, :href => feed_url)
  end
end
