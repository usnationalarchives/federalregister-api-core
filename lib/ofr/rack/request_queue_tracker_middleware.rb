require_relative "../../request_queue_tracker"

module Ofr
  module Rack
    class RequestQueueTrackerMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        RequestStore[:request_queue_tracking] = RequestQueueTracker.new(env)
        @app.call(env)
      end
    end
  end
end
