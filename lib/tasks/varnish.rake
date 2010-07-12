namespace :varnish do
  desc "Start varnish, recompiling config if necessary"
  task :start do
    `varnishd -f config/varnish.development.vcl -a 0.0.0.0:8080 -s malloc,10M -T 127.0.0.1:6082`
    puts "please visit http://fr2.local:8080/"
  end
  
  desc "Stop varnish"
  task :stop do
    `killall varnishd`
    puts "varnish shutting down..."
  end

  desc "Restart varnish"
  task :restart => [:stop, :start]
end