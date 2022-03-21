Rails.application.configure do
  config.lograge.enabled                 = true
  config.lograge.base_controller_class   = 'ActionController::Base'
  config.lograge.formatter               = Lograge::Formatters::Json.new

  config.lograge.ignore_actions = [
    'SpecialController#status',
  ]

  config.lograge.custom_payload do |controller|
    exceptions = %w()
    {
      host:   controller.request.host,
      ip: controller.request.remote_ip,
      params: controller.request.filtered_parameters.except(*exceptions),
      pid: Process.pid,
      env: Rails.env,
      referrer: controller.request.referrer,
      request_uuid: controller.request.uuid,
      status: controller.response.status,
      user_agent: controller.request.env["HTTP_USER_AGENT"]
    }
  end

  config.lograge.custom_options = lambda do |event|
    if event.payload[:exception]
      {
        exception_class: event.payload[:exception][0],
        exception_message: event.payload[:exception][1],
        backtrace: event.payload[:exception_object].backtrace&.join("; ")
      }
    else
      options = {}
      options[:memory_usage] = event.payload[:memory_usage] if event.payload[:memory_usage]
      options
    end
  end
end
