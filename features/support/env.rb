require 'webrat'
require 'mechanize'

Webrat.configure do |config|
  config.mode = :mechanize
end

secrets = YAML::load_file 'config/secrets.yml'
host = ENV['CUCUMBER_HOST'] || 'www.federalregister.gov'

World do
  session = Webrat::Session.new()
  session.extend(Webrat::Methods)
  session.extend(Webrat::Matchers)

  url = "http://#{host}"
  session.visit(url) # sets the default URL, hits the cache

  # cookie = Mechanize::Cookie.new('skip_cache', secrets['varnish']['skip_cache_key'])
  # cookie.domain = "#{host}"
  # cookie.path = "/"
  # session.webrat_session.adapter.mechanize.cookie_jar.add(URI.parse(url), cookie)
  session
end
