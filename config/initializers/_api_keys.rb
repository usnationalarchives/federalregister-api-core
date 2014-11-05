config = YAML::load(File.open("#{RAILS_ROOT}/config/secrets.yml"))['api_keys']

config.each_pair do |key, value|
  ENV["#{key}_api_key"] = value
end
