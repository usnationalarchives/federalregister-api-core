# require 'activesupport'

module ActiveSupport
  # port from Rails 3 where binmode is forced on the log stream to deal with encoding issues
  class BinaryBufferedLogger < BufferedLogger
    def initialize(log, level = DEBUG)
      @level         = level
      @buffer        = Hash.new { |h,k| h[k] = [] }
      @auto_flushing = 1
      @guard = Mutex.new

      if log.respond_to?(:write)
        @log = log
      elsif File.exist?(log)
        @log = open(log, (File::WRONLY | File::APPEND))
        @log.binmode
        @log.sync = true
      else
        FileUtils.mkdir_p(File.dirname(log))
        @log = open(log, (File::WRONLY | File::APPEND | File::CREAT))
        @log.binmode
        @log.sync = true
      end
    end
  end
end
