# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include PathHelper
  include RouteBuilder
  
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include Locator
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :load_ticker_entries
  
  private
  
  # this way helpers included in the controller can reference the controller in the same way
  def controller
    self
  end
  
  def load_ticker_entries
    @ticker_entries = Entry.all(:conditions => ['publication_date = ?', Entry.latest_publication_date], :include => :agency)
  end
end
