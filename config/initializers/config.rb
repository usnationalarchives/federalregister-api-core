Config.setup do |config|
  config.const_name = "Settings"
  config.use_env = true
  config.env_prefix = 'SETTINGS'
  config.env_separator = "__"
  # try to parse values to a correct type (Boolean, Integer, Float, String)
  config.env_parse_values = true
end
