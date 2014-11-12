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
        :conditions => {:publication_date => date .. Time.current.to_date},
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
      dates = [Time.current.to_date]
    end
  end

  def self.run_myfr2_command(command)
    old_gemfile = ENV['BUNDLE_GEMFILE']
    Dir.chdir("/var/www/apps/federalregister-web") do
      ENV['BUNDLE_GEMFILE'] = nil
      puts "running MyFR command: '#{command}'"
      system(command) or raise "Error when calling '#{command}'"
    end
  ensure
    ENV['BUNDLE_GEMFILE'] = old_gemfile
  end

  def self.render_erb(template_path, locals = {})
    view = ActionView::Base.new(Rails::Configuration.new.view_path, {})
    [
      ActionView::Helpers::UrlHelper,
      ActionController::UrlWriter,
      ApplicationHelper,
      HandlebarsHelper,
      HtmlHelper,
      Html5Helper,
      CitationsHelper,
      Citations::CfrHelper,
      XsltHelper,
      RegulatoryPlanHelper,
      TextHelper
    ].each do |mod|
      view.extend mod
    end
    
    class << view.class
      def default_url_options
        {:host => "federalregister.gov"}
      end
    end
    
    # Monkeypatching url_for to deal with this issue: https://rails.lighthouseapp.com/projects/8994/tickets/1560#ticket-1560-4
    class << view
      include RouteBuilder
      def url_for_with_string_support(options)
        if String === options
          options
        else
          url_for_without_string_support(options)
        end
      end
      
      alias_method_chain :url_for, :string_support
    end

    if template_path =~ /\.erb$/
      path = template_path
    else
      path = "#{template_path}.html.erb"
    end

    
    view.render(:file => path, :locals => locals)
  end
end
