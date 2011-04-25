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
  
  add_route :entry do |entry|
    {
      :year            => entry.publication_date.strftime('%Y'),
      :month           => entry.publication_date.strftime('%m'),
      :day             => entry.publication_date.strftime('%d'),
      :document_number => entry.document_number,
      :slug            => entry.slug
    }
  end
  
  def entry_full_text_path(entry)
    "/articles/html/full_text/#{entry.document_file_path}.html"
  end
  
  def entry_abstract_path(entry)
    "/articles/html/abstract/#{entry.document_file_path}.html"
  end
  
  def entry_xml_path(entry)
    "/articles/xml/#{entry.document_file_path}.xml"
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
    host = 'federalregister.gov' if RAILS_ENV == 'production'
    {
      :document_number => entry.document_number,
      :host => host
    }
  end
  
  add_route :place do |place|
    {
      :slug => place.slug,
      :id   => place.id
    }
  end
  
  add_route :entries_by_month do |date|
    {
      :year            => date.strftime('%Y'),
      :month           => date.strftime('%m')
    }
  end
    
  add_route :entries_by_date do |date|
    {
      :year            => date.strftime('%Y'),
      :month           => date.strftime('%m'),
      :day             => date.strftime('%d'),
    }
  end
  
  add_route :entry_statistics_by_date do |date|
    {
      :year            => date.strftime('%Y'),
      :month           => date.strftime('%m'),
      :day             => date.strftime('%d'),
    }
  end
  
  add_route :new_entry_email do |entry|
    {
      :document_number => entry.document_number,
    }
  end
  
  add_route :entry_email do |entry|
    {
      :document_number => entry.document_number,
    }
  end
  
  add_route :delivered_entry_email do |entry|
    {
      :document_number => entry.document_number,
    }
  end
  
  add_route :section do |section|
    {
      :slug => section.slug
    }
  end
  
  add_route :regulatory_plan do |regulatory_plan|
    {
      :regulation_id_number => regulatory_plan.regulation_id_number,
      :slug => regulatory_plan.slug
    }
  end
  
  add_route :regulatory_plan_timeline do |regulatory_plan|
    {
      :regulation_id_number => regulatory_plan.regulation_id_number
    }
  end
  
  def regulatory_plan_full_text_path(regulatory_plan)
    "/regulations/html/full_text/#{regulatory_plan.regulation_id_number}.html"
  end
  
  def regulatory_plan_contacts_path(regulatory_plan)
    "/regulations/html/contacts/#{regulatory_plan.regulation_id_number}.html"
  end
  
  def regulatory_plan_sidebar_path(regulatory_plan)
    "/regulations/html/sidebar/#{regulatory_plan.regulation_id_number}.html"
  end
  
  add_route :short_regulatory_plan do |regulatory_plan|
    {
      :regulation_id_number => regulatory_plan.regulation_id_number,
    }
  end
  
  # keep at bottom of module
  def self.included(base)
    instance_methods.each do |method|
      next if method !~ /(?:_path|_url)$/
      
      # allow this module to be mixed in outside of controllers...
      if base < ActionController::Base
        base.instance_eval do
          helper_method method
        end
      end
    end
  end
end
