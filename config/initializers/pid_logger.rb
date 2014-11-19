# source: http://gist.github.com/452539
# thanks to EP on
# http://groups.google.com/group/phusion-passenger/
# browse_thread/thread/a3221e0e15adc1ec
# [logger per worker]

# add it to config/initializer in rails
# tested with rails-2.3.17

# simply giving the pid in the config will not work as it will be the
# pid of the ApplicationSpawner and not the worker
#

# modified to move pid to front of messages

unless defined? Logger
  require 'logger'
  #puts "==== requiring logger (pid: #{$$})"
end

unless defined? ActiveSupport::BufferedLogger
  require 'active_support'
  #puts "==== requiring active_support (pid: #{$$})"
end

class Logger
  class Formatter
    private
    def msg2str(msg)
      case msg
      when ::String
        "[PID: #{$$}] #{msg}"
      when ::Exception
        "[PID: #{$$}] #{ msg.message } (#{ msg.class })\n" <<
          ["[PID: #{$$}]\n"].join(msg.backtrace || [])
      else
        "[PID: #{$$}] #{msg.inspect}"
      end
    end
  end

  # Simple formatter which only displays the message.
  class SimpleFormatter < Logger::Formatter
    # This method is invoked when a log event occurs
    def call(severity, timestamp, progname, msg)
      "[PID: #{$$}] #{String === msg ? msg : msg.inspect}\n"
    end
  end

  private
  def msg2str(msg) "[PID: #{$$}] #{msg}" end
end

module ActiveSupport
  # Inspired by the buffered logger idea by Ezra
  class BufferedLogger
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      if message[-1] == ?\n
        message = "[PID: #{$$}] #{message[0..-2]}\n"
      else
        message = "[PID: #{$$}] #{message}\n"
      end
      buffer << message
      auto_flush
      message
    end
  end
end
