module RouteBuilder
  include RouteBuilder::MyFederalRegister

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
  
  def self.add_static_route(route_name, &proc)
    define_method "#{route_name}_path" do |*args|
      proc.call(*args)
    end
    
    define_method "#{route_name}_url" do |*args|
      root_url.sub(/\/$/,'') + proc.call(*args)
    end
  end
  
  def self.add_api_route(route_name, &proc)
    base_route = "api_v1_#{route_name}"
    
    define_method "#{base_route}_url" do |*args|
      if Rails.env == 'staging'
        base_url = 'http://api.fr2.criticaljuncture.org'
      elsif Rails.env == 'production'
        base_url = 'http://api.federalregister.gov'
      else
        base_url = 'http://api.fr2.local:8080'
      end
      
      base_url + send("#{base_route}_path", *args).sub(/^\/api\//, '/')
    end
  end
  
  add_api_route :entry
  add_api_route :entries
  add_api_route :agency
  add_api_route :agencies
  add_api_route :public_inspection_document
  add_api_route :public_inspection_documents
  
  add_route :citation do |vol,page|
    {
      :fr_citation => "#{vol}-FR-#{page}"
    }
  end
  
  add_route :entry do |entry|
    {
      :year            => (entry.publication_date || entry.filed_at.to_date).strftime('%Y'),
      :month           => (entry.publication_date || entry.filed_at.to_date).strftime('%m'),
      :day             => (entry.publication_date || entry.filed_at.to_date).strftime('%d'),
      :document_number => entry.document_number,
      :slug            => entry.slug
    }
  end
  
  add_static_route :entry_full_text do |entry|
    "/articles/html/full_text/#{entry.document_file_path}.html"
  end
  
  add_static_route :entry_abstract do |entry|
    "/articles/html/abstract/#{entry.document_file_path}.html"
  end
  
  add_static_route :entry_xml do |entry|
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
 
  add_route :public_inspection_documents_by_month do |date|
    {
      :year            => date.strftime('%Y'),
      :month           => date.strftime('%m')
    }
  end
    
  add_route :public_inspection_documents_by_date do |date|
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
  
  add_static_route :regulatory_plan_full_text do |regulatory_plan|
    "/regulations/html/full_text/#{regulatory_plan.regulation_id_number}.html"
  end
  
  add_static_route :regulatory_plan_contacts do |regulatory_plan|
    "/regulations/html/contacts/#{regulatory_plan.regulation_id_number}.html"
  end
  
  add_static_route :regulatory_plan_sidebar do |regulatory_plan|
    "/regulations/html/sidebar/#{regulatory_plan.regulation_id_number}.html"
  end
  
  add_route :cfr_citation do |year, title, part, section |
    {
      :year            => year.to_s,
      :citation        => "#{title}-CFR-#{part}#{'.' + section.to_s if section.present?}"
    }
  end
  
  add_route :select_cfr_citation do |date, title, part, section |
    {
      :year            => date.strftime('%Y'),
      :month           => date.strftime('%m'),
      :day             => date.strftime('%d'),
      :citation        => "#{title}-CFR-#{part}#{'.' + section if section.present?}"
    }
  end
  
  add_route :short_regulatory_plan do |regulatory_plan|
    {
      :regulation_id_number => regulatory_plan.regulation_id_number,
    }
  end

  add_route :canned_search do |canned_search|
    {
      :slug => canned_search.slug
    }
  end

  # keep at bottom of module
  def self.included(base)
    instance_methods.each do |method|
      next if method !~ /(?:_path|_url)$/
      
      # allow this module to be mixed in outside of controllers...
      if base < ActionController::Base || base < ActionMailer::Base
        base.instance_eval do
          helper_method method
        end
      end
    end
  end
end
