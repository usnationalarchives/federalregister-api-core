require "lograge/sql/extension" if Settings.lograge.enabled

Rails.application.configure do
  config.lograge.enabled = Settings.lograge.enabled
  config.lograge.base_controller_class   = "ActionController::Base"

  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.logger = ActiveSupport::Logger.new($stdout)

  config.lograge.ignore_actions = [
    "SpecialController#alive",
    "SpecialController#status",
  ]

  config.lograge.custom_payload do |controller|
    exceptions = %w[]
    {
      env: Rails.env,
      host: controller.request.host,
      ip: controller.request.remote_ip,
      params: controller.request.filtered_parameters.except(*exceptions),
      pid: Process.pid,
      referrer: controller.request.referrer,
      request_uuid: controller.request.uuid,
      status: controller.response.status.to_s,
      user_agent: controller.request.env["HTTP_USER_AGENT"]
    }
  end

  config.lograge.custom_options = lambda do |event|
    custom_options = {}

    if event.payload[:exception]
      custom_options.merge({
        exception_class: event.payload[:exception][0],
        exception_message: event.payload[:exception][1],
        backtrace: event.payload[:exception_object].backtrace&.join("; ")
      })
    end

    custom_options[:memory_usage] = RequestStore[:memory_usage]
    custom_options[:queue_time] = RequestStore[:request_queue_tracking]&.time_in_queue

    custom_options
  end
end
