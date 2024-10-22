MEMORY_STORE = ActiveSupport::Cache::RedisCacheStore.new(
  redis: $redis,
  compress: false
)
