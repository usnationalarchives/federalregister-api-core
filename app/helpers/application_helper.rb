# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def title(text)
    content_for :title, text
  end
  
  def feed_autodiscovery(feed_url, title = 'RSS')
    content_for :feeds, content_tag(:link, nil, :rel => 'alternate', :type => 'application/rss+xml', :title => title, :href => feed_url)
  end
end
