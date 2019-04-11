class CacheExpirer < ActiveRecord::Observer
  include CacheUtils

  # Load up all the routing...
  include ActionController::UrlWriter
  include ApplicationHelper
  include RouteBuilder
end
