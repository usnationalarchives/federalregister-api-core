# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include RouteBuilder
  include ViewHelper
  
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include Locator
  
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  
  private
  
  rescue_from Exception, :with => :server_error if RAILS_ENV != 'development'
  def server_error(exception)
    notify_hoptoad(exception)
    
    request.format = :html
    render :template => "errors/500.html.erb", :status => 500
  end
  
  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, :with => :record_not_found if RAILS_ENV != 'development'
  def record_not_found
    request.format = :html
    render :template => "errors/404.html.erb", :status => 404
  end
end
