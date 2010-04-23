require 'rubygems'
require 'yaml'

class CloudConfigure
  
  def initialize
    configure
  end
  
  def run
    web_group_setup
    #database_group_setup
  end

  # sets up web server group firewall
  def web_group_setup
    puts "***\n\nSetting up web group\n\n***"
    `ec2-add-group web -d "Web server group"`
    `ec2-authorize -p 80 web` # http
    `ec2-authorize -p 22 web` # ssh
    `ec2-authorize -P icmp -t -1:-1 web` # ping
  end
  
  # sets up web server group firewall
  def database_group_setup
    puts "***\n\nSetting up database group\n\n***"
    `ec2-add-group database -d "Database server group"`
    `ec2-authorize -p 22 database` # ssh
    `ec2-authorize -P icmp -t -1:-1 database` # ping
    `ec2-authorize database -o web -u #{@aws_account_id}`
  end
  
  private
  
  def configure
    config = YAML::load(File.open("#{File.dirname(__FILE__)}/../config/amazon.yml"))
    config.each_pair do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
  end
end

puts CloudConfigure.new.run