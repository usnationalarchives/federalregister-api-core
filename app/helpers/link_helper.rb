module LinkHelper
  def link_to_twitter(status)
    href = "http://twitter.com/home?status=#{CGI.escape status}"
    link_to('Twitter', href, :target => :blank, :title => 'Twitter', :class => 'button list social twitter')
  end
  
  def link_to_facebook(url, title)
    link_to "Facebook", "http://www.facebook.com/sharer.php?u=#{CGI.escape url}&t=#{CGI.escape title}", :target => :blank, :class => 'button list fb_link social facebook'
  end
  
  def link_to_digg(url, title, description)
    href        = "http://digg.com/submit?url=#{CGI.escape url}&title=#{CGI.escape truncate_words(title, :length => 75)}&bodytext=#{CGI.escape truncate_words(description, :length => 350)}&media=news"
    link_to('Digg', href, :target => :blank, :title => 'Digg', :class => 'button list social digg')
  end
  
  def link_to_reddit(url, title)
    link_to "Reddit", "http://www.reddit.com/submit?url=#{CGI.escape url}&title=#{CGI.escape title}", :target => :blank, :class => 'button list reddit_link social reddit'
  end
end