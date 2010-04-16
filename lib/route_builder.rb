module RouteBuilder
  def self.add_route(route_name, &proc)
    %w(path url).each do |type|
      new_method_name = "#{route_name}_#{type}"      # eg entry_path
      define_method new_method_name do |*args|
        options = args.extract_options! || {}
        
        if args.size > 0
          route_params = proc.call(*args)
          options.reverse_merge!(route_params)
        end
        
        super(options)
      end
    end
  end
  
  def entries_path(options = {})
    options.symbolize_keys!
    
    if options[:format] == :rss
      'http://feeds.feedburner.com/GovPulseLatestEntries'
    else
      super
    end
  end
  
  add_route :entry do |entry|
    {
      :year            => entry.publication_date.strftime('%Y'),
      :month           => entry.publication_date.strftime('%m'),
      :day             => entry.publication_date.strftime('%d'),
      :document_number => entry.document_number,
      :slug            => entry.slug
    }
  end
  
  add_route :entry_citation do |entry|
    {
      :year            => entry.publication_date.strftime('%Y'),
      :month           => entry.publication_date.strftime('%m'),
      :day             => entry.publication_date.strftime('%d'),
      :document_number => entry.document_number,
      :slug            => entry.slug
    }
  end
  
  add_route :short_entry do |entry|
    host = 'fr2.criticaljuncture.org' if RAILS_ENV == 'production'
    {
      :document_number => entry.document_number,
      :host => host
    }
  end
  
  add_route :events do |date|
    {
      :year            => date.strftime('%Y'),
      :month           => date.strftime('%m')
    }
  end
  
  add_route :place do |place|
    {
      :slug => place.slug,
      :id   => place.id
    }
  end
  
  add_route :entries_by_date do |date|
    {
      :year            => date.strftime('%Y'),
      :month           => date.strftime('%m'),
      :day             => date.strftime('%d'),
    }
  end
  
  # keep at bottom of module
  def self.included(base)
    instance_methods.each do |method|
      next if method !~ /(?:_path|_url)$/
      
      base.instance_eval do
        helper_method method
      end
    end
  end
end
