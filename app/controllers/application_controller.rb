# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include RouteBuilder
  include ViewHelper
  
  include Locator

  before_filter do
    self.request_forgery_protection_token = nil
  end
 
  # turn IP Spoofing detection off.
  ActionController::Base.ip_spoofing_check = false

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  
  private
  def parse_date_from_params
    year  = params[:year]
    month = params[:month]
    day   = params[:day]
    begin
      Date.parse("#{year}-#{month}-#{day}")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end
  end

  rescue_from Exception, :with => :server_error if RAILS_ENV != 'development'
  def server_error(exception)
    Rails.logger.error(exception)
    notify_airbrake(exception)
    
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render :nothing => true, :status => 500
    else
      request.format = :html
      render :template => "errors/500.html.erb", :status => 500
    end
  end
  
  rescue_from ActiveRecord::RecordNotFound, ActiveHash::RecordNotFound, ActionController::RoutingError, :with => :record_not_found if RAILS_ENV != 'development'
  def record_not_found
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      render :nothing => true, :status => 404
    else
      request.format = :html
      render :template => "errors/404.html.erb", :status => 404
    end
  end
  
  rescue_from ActionController::MethodNotAllowed, :with => :method_not_allowed
  def method_not_allowed
    if params[:quiet]
      render :nothing => true, :status => 405
    else
      request.format = :html
      render :template => "errors/405.html.erb", :status => 405
    end
  end
  
  def cache_for(time)
    if RAILS_ENV == 'development'
      path = File.join(Rails.root, 'config', 'cache.yml')
      if File.exists?(path) && YAML::load_file(path).none? {|path| request.path =~ /#{path}/ }
        return
      end
    end
    expires_in time, :public => true
  end
  
  def template_exists?(template_name = default_template_name)
    self.view_paths.find_template(template_name, response.template.template_format)
  rescue ActionView::MissingTemplate
    false
  end
  
  def handle_unverified_request
    raise "Invalid Authenticity Token"
  end

  def ab_group
    cookies[:ab_group]
  end
  helper_method :ab_group
end
