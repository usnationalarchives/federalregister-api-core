class RequestQueueTracker
  attr_reader :time_in_queue

  def initialize(env)
    @x_request_start = env["HTTP_X_REQUEST_START"]
    @request_started_at = Time.now.to_f
    @time_in_queue = calculate_time_in_queue
  end

  def calculate_time_in_queue
    return nil if request_queued_at.blank?

    (@request_started_at - request_queued_at).round(2)
  end

  def request_queued_at
    return nil if @x_request_start.blank?

    @x_request_start.to_f
  end
end
