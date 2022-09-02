SETTINGS = YAML.unsafe_load(
  ERB.new(
    File.read(
      File.join(File.dirname(__FILE__), '..', 'settings.yml')
    )
  ).result
)[Rails.env]

RAILS_ENV = ENV["RAILS_ENV"] || Rails.env
