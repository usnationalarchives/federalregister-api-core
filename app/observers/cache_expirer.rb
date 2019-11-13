class CacheExpirer < ActiveRecord::Observer
  include CacheUtils

  # Load up all the routing...
  include Rails.application.routes.url_helpers
  include ApplicationHelper
  include RouteBuilder
end
