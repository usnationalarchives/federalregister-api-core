SECRETS = YAML::load(
  ERB.new(
    File.read(
      File.join(File.dirname(__FILE__), '..', 'secrets.yml')
    )
  ).result
)
