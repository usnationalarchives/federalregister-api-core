module Content::EntryImporter::Urls
  extend Content::EntryImporter::Utils
  provides :urls
  
  def urls
    urls = []
    mods_node.css('urlRef').each do |url_ref|
      url = clean_url(url_ref.content)
      urls << Url.find_or_create_by_name(url)
    end
    
    urls
  end
  
  private
  
  def clean_url(url)
    if url =~ /^[a-z]+:\/\//
      url
    else
      "http://#{url}"
    end
  end
  
end