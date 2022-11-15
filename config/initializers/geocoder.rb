Geocoder.configure(
  lookup: :geoapify,
  api_key: Rails.application.secrets[:api_keys][:geoapify],
  cache: $redis
)
