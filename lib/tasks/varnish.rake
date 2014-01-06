namespace :varnish do
  namespace :config do
    task :generate do
      File.open(File.join(Rails.root, 'config', "varnish.#{RAILS_ENV}.vcl"), 'w') do |f|
        template_content = IO.read(File.join(Rails.root, 'config', "varnish.vcl.erb"))
        config = varnish_config
        secrets = YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
        skip_cache_key = secrets['varnish']['skip_cache_key']
        f.write ERB.new(template_content).result(binding)
      end
    end
  end

  desc "Start varnish, recompiling config if necessary"
  task :start => 'varnish:config:generate' do
     config = varnish_config
    `varnishd -f config/varnish.#{RAILS_ENV}.vcl -a 0.0.0.0:#{config["port"]} -s malloc,10M -T 127.0.0.1:#{config["management_port"]} -n #{RAILS_ENV} -P #{File.join(Rails.root, 'tmp', "#{RAILS_ENV}_varnish.pid")}`
    puts "please visit http://fr2.local:#{config["port"]}/"
  end

  desc "Stop varnish"
  task :stop do
    pid_file_path = File.join(Rails.root, 'tmp', "#{RAILS_ENV}_varnish.pid")

    if File.exists?(pid_file_path)
      pid = IO.read(pid_file_path).strip
      `kill -9 #{pid}`
      puts "varnish shutting down..."
      FileUtils.rm(pid_file_path)
    else
      puts "no pid file at #{pid_file_path}, unable to stop varnish (perhaps not running?)"
    end
  end

  task :dump_vcl do
    puts `varnishd -f config/varnish.#{RAILS_ENV}.vcl -d -C`
  end

  desc "Restart varnish"
  task :restart => [:stop, :start]

  def varnish_config
    yml_path = File.join(Rails.root, 'config', 'varnish.yml')
    if File.exists?(yml_path)
      config = YAML::load_file(yml_path)
      config = config[RAILS_ENV]
    else
      config = {:wordpress => {}, :rails => {}, :port => 8080}
    end
  end


  namespace :expire do
    desc "Expire everything from varnish"
    task :everything => :environment do
      include CacheUtils
      purge_cache(".*")
    end

    desc "Expire from varnish pages so that late notice can go up"
    task :pages_warning_of_late_content => :environment do
      if Issue.current_issue_is_late?
        Mailer.deliver_admin_notification("Today's issue #{Time.current.to_date} on #{RAILS_ENV} is late. There may have been a problem!")

        include CacheUtils
        purge_cache("/")
        purge_cache("/articles/#{Time.current.to_date.strftime('%Y')}/#{Time.current.to_date.strftime('%m')}")
      end
    end
  end
end
