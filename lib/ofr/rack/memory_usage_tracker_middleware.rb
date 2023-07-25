module Ofr
  module Rack
    require_relative "../../concerns/process_concerns"

    class MemoryUsageTrackerMiddleware
      include ProcessConcerns
      def initialize(app)
        @app = app
      end

      def call(env)
        RequestStore[:memory_usage] = {start: maxrss}
        @app.call(env)
      end
    end
  end
end
