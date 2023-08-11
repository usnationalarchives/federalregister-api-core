module ExclusiveLock
  def self.lock(key, expires: 1.hour, options: {})
    default_options = {retain_lock: false}
    options = default_options.merge(options)

    key = "lock:#{key}"
    if $redis.setnx(key, Socket.gethostname)
      $redis.expire(key, expires)
      begin
        yield
      ensure
        $redis.del(key) unless options[:retain_lock]
      end
    end
  end

  def self.unlock(key)
    $redis.del("lock:#{key}")
  end
end
