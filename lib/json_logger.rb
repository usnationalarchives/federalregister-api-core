class JsonLogger < ActiveSupport::Logger::SimpleFormatter
  def call(severity, timestamp, _progname, message)
    json = {
      type: severity,
      time: timestamp,
      msg: message
    }.to_json

    "#{json}\n"
  end
end
