ActiveSupport::Notifications.subscribe('deprecation.rails') do |name, start, finish, id, payload|
  Honeybadger.notify(
    error_class:   "deprecation_warning",
    error_message: payload[:message],
    backtrace:     payload[:callstack]
  )
end
