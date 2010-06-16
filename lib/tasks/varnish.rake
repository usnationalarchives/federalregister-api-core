namespace :varnish do
  task :start do
    `varnishd -f config/varnish.development.vcl -a 0.0.0.0:8080`
    puts "please visit http://fr2.local:8080/"
  end
  
  task :stop do
    `killall varnishd`
    puts "varnish shutting down"
  end
end