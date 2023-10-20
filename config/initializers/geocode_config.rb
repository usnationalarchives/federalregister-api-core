Geokit::Geocoders::GoogleGeocoder.api_key = Rails.application.credentials.dig(:google, :maps, :geocode_api_key)
Geokit::Geocoders::ip_provider_order = ['geoip']
