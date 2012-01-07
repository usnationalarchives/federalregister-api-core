config = YAML::load(File.open("#{RAILS_ROOT}/config/api_keys.yml"))

config.each_pair do |key, value|
  ENV["#{key}_api_key"] = value
end