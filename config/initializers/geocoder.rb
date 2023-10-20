Geocoder.configure(
  lookup: :geoapify,
  api_key: Rails.application.credentials.dig(:geoapify, :api_key),
  cache: $redis
)
