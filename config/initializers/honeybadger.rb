Honeybadger.configure do |config|
  config.revision = Settings.container.revision

  config.before_notify << lambda do |notice|
    notice.context.merge!(
      application: "api-core",
      deployment_environment: Settings.container.role,
      tags: "#{Settings.container.process}_process, #{Settings.container.role}",
      revision: Settings.container.revision
    )
  end
end
