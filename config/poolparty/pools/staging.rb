require 'config/poolparty/pool_helper.rb'

pool :fr2_staging do
  #eval_file File.join(File.dirname(__FILE__), 'staging', 'proxy_server.rb')
  eval_file File.join(File.dirname(__FILE__), 'staging', 'app_server.rb')
  #eval_file File.join(File.dirname(__FILE__), 'staging', 'database_server.rb')
  #eval_file File.join(File.dirname(__FILE__), 'staging', 'static_server.rb')
end
