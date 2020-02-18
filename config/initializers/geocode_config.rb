Geokit::Geocoders::GoogleGeocoder.api_key = Rails.application.secrets[:api_keys][:google_maps_geocode]
Geokit::Geocoders::ip_provider_order = ['geoip']
