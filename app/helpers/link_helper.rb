module LinkHelper
  def link_to_twitter(entry)
    twitter_url = 'http://twitter.com/home?'
    message = "Make your voice heard! "
    hash_tag = "%23gov20"
    status = "status=#{message} #{short_entry_url(entry)} #{hash_tag}"
    href = twitter_url + status
    link_to('Twitter', href, :target => :blank, :title => 'Twitter', :class => 'button list')
  end
  
  def link_to_facebook(entry)
    add_javascript do
      "<script type='text/javascript'>
        $(document).ready(function() {
          $('.fb_link').bind('click', function(e){
            e.preventDefault();
            u = '#{short_entry_url(entry)}';
            t = document.title;
            window.open('http://www.facebook.com/sharer.php?u='+encodeURIComponent(u)+'&t='+encodeURIComponent(t),'sharer','toolbar=0,status=0');
          });
        });
      </script>"
    end

    return "<a href='http://www.facebook.com/share.php' title='Facebook' class='button list fb_link'>Facebook</a>"
  end
  
  def link_to_digg(entry)
    url         = short_entry_url(entry)
    title       = truncate(entry.title, :length => 72) #digg max of 75
    description = entry.abstract.nil? ? '' : truncate(entry.abstract, :length => 347) #digg max of 350
    media       = 'news'
    href        = "http://digg.com/submit?url=#{url}&title=#{title}&bodytext=#{description}&media=#{media}"
    link_to('Digg', href, :target => :blank, :title => 'Digg', :class => 'button list')
  end
  
  def link_to_reddit(entry)
    add_javascript do
      "<script type='text/javascript'>
        $(document).ready(function() {
          $('.reddit_link').bind('click', function(e){
            e.preventDefault();
            u = '#{short_entry_url(entry)}';
            window.open('http://www.reddit.com/submit?url='+encodeURIComponent(u),'','toolbar=0,status=0');
          });
        });
      </script>"
    end
    return "<a href='http://www.reddit.com/submit' title='Reddit' class='button list reddit_link'>Reddit</a>"
  end
  
  def clippy(text, bgcolor='#E8F8FC')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="14"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="wmode" value="transparent"> 
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             wmode="transparent" 
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
      />
      </object>
    EOF
    html
  end
end