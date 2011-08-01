module LinkHelper
  def link_to_twitter(status)
    href = "http://twitter.com/home?status=#{CGI.escape status}"
    link_to('Twitter', href, :target => :blank, :title => 'Twitter', :class => 'button list social twitter')
  end
  
  def link_to_facebook(url, title)
    link_to "Facebook", "http://www.facebook.com/sharer.php?u=#{CGI.escape url}&t=#{CGI.escape title}", :target => :blank, :class => 'button list fb_link social facebook', :title => "Facebook"
  end
  
  def link_to_digg(url, title, description)
    href        = "http://digg.com/submit?url=#{CGI.escape url}&title=#{CGI.escape truncate_words(title, :length => 75)}&bodytext=#{CGI.escape truncate_words(description || '', :length => 350)}&media=news"
    link_to('Digg', href, :target => :blank, :title => 'Digg', :class => 'button list social digg')
  end
  
  def link_to_reddit(url, title)
    link_to "Reddit", "http://www.reddit.com/submit?url=#{CGI.escape url}&title=#{CGI.escape title}", :target => :blank, :class => 'button list reddit_link social reddit', :title => "Reddit"
  end

  def clippy(text, bgcolor='#F5F8F9')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end
end
