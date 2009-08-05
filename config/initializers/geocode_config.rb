google_config = YAML::load(File.open("#{RAILS_ROOT}/config/google_maps.yml"))
Geokit::Geocoders::google = google_config['application_id']