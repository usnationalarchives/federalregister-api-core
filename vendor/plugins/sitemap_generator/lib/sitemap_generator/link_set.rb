module SitemapGenerator
  class LinkSet
    attr_accessor :default_host, :yahoo_app_id, :links, :subdirectory
    
    def initialize
      @links = []
      @subdirectory = ''
    end

    def default_host=(host)
      @default_host = host
    end

    def add_default_links
      # Add default links
      @links << Link.generate('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
      @links << Link.generate(File.join(subdirectory, 'sitemap_index.xml.gz'), :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
    end
    
    def add_links
      add_default_links if @links.empty?
      yield Mapper.new(self)
    end
    
    def add_link(link)
      @links << link
    end
  end
end