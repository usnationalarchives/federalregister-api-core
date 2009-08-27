module LinkHelper
  def link_to_twitter(entry)
    twitter_url = 'http://twitter.com/home?'
    message = "From the Federal Register: "
    hash_tag = "%23itsourgovt"
    status = "status=#{message} #{short_entry_url(entry)} #{hash_tag}"
    href = twitter_url + status
    link_to('Tweet This', href, :target => :blank)
  end
  
  def link_to_facebook(entry)
    add_javascript do
      "<script>
        function fbs_click() {
          u=location.href;
          t=document.title;
          window.open('http://www.facebook.com/sharer.php?u='+encodeURIComponent(u)+'&t='+encodeURIComponent(t),'sharer','toolbar=0,status=0,width=626,height=436');
          return false;
        }
      </script>"
    end

    return '<a href="http://www.facebook.com/share.php?u=<url>" onclick="return fbs_click()" target="_blank">Share on Facebook</a>'
  end
end