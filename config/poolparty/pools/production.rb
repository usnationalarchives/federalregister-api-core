require 'config/poolparty/pool_helper.rb'

pool :fr2 do
  eval_file File.join(File.dirname(__FILE__), 'production', 'proxy_server.rb')
  eval_file File.join(File.dirname(__FILE__), 'production', 'app_server.rb')
  eval_file File.join(File.dirname(__FILE__), 'production', 'database_server.rb')
  eval_file File.join(File.dirname(__FILE__), 'production', 'static_server_large.rb')
end