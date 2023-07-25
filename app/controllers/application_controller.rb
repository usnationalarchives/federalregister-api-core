# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include RouteBuilder
  include ViewHelper

  include Locator

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

  rescue_from Exception, :with => :server_error if RAILS_ENV == 'production' || RAILS_ENV == 'staging'
  def server_error(exception)
    Rails.logger.error(exception)
    Honeybadger.notify(exception)

    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      head 500
    else
      request.format = :html
      render :template => "errors/500.html.erb", :status => 500
    end
  end

  rescue_from ActiveRecord::RecordNotFound, ActiveHash::RecordNotFound, ActionController::RoutingError, :with => :record_not_found if RAILS_ENV != 'development'
  def record_not_found
    # ESI routes should return correct status codes, but no error page
    if params[:quiet]
      head 404
    else
      request.format = :html
      render :template => "errors/404.html.erb", :status => 404
    end
  end

  rescue_from ActionController::MethodNotAllowed, :with => :method_not_allowed
  def method_not_allowed
    if params[:quiet]
      head 405
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

  def handle_unverified_request
    raise "Invalid Authenticity Token"
  end

  def ab_group
    cookies[:ab_group]
  end
  helper_method :ab_group
end
