module Content
  def self.parse_dates(date)
    if date == 'all'
      dates = Entry.find_as_array(
        :select => "distinct(publication_date) AS publication_date",
        :order => "publication_date"
      )
    elsif date =~ /^>/
      date = Date.parse(date.sub(/^>/, ''))
      dates = Entry.find_as_array(
        :select => "distinct(publication_date) AS publication_date",
        :conditions => {:publication_date => date .. Date.today},
        :order => "publication_date"
      )
    elsif date =~ /^\d{4}$/
      dates = Entry.find_as_array(
        :select => "distinct(publication_date) AS publication_date",
        :conditions => {:publication_date => Date.parse("#{date}-01-01") .. Date.parse("#{date}-12-31")},
        :order => "publication_date"
      )
    elsif date.present?
      dates = [date.is_a?(String) ? date : date.to_s(:iso)]
    else
      dates = [Date.today]
    end
  end
  
  def self.render_erb(template_path, locals = {})
    view = ActionView::Base.new(Rails::Configuration.new.view_path, {})
    [ActionView::Helpers::UrlHelper, ActionController::UrlWriter, ApplicationHelper, CitationsHelper, XsltHelper].each do |mod|
      view.extend mod
    end
    
    class << view.class
      def default_url_options
        {}
      end
    end
    
    view.render(:file => "#{template_path}.html.erb", :locals => locals)  
  end
end