module LinkHelper
  def link_to_twitter(status)
    href = "http://twitter.com/home?status=#{CGI.escape status}"
    link_to('Twitter', href, :target => :blank, :title => 'Share on Twitter', :class => 'button list social twitter tip_over')
  end

  def link_to_facebook(url, title)
    link_to "Facebook", "http://www.facebook.com/sharer.php?u=#{CGI.escape url}&t=#{CGI.escape title}", :target => :blank, :class => 'button list fb_link social facebook tip_over', :title => "Share on Facebook"
  end

  def clippy(text, bgcolor='#F5F8F9')
    clippy_path = "/flash/clippy.swf"
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="#{clippy_path}"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="#{clippy_path}"
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
