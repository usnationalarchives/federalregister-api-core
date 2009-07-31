namespace :data do
  namespace :download do
    task :entries => :environment do
      require "open-uri"
      
      date = Date.today + 1
      end_date = Date.parse('1994-01-01')
      
      while(date >= end_date)
        date = date - 1
        next if date.wday == 6 || date.wday == 0
        
        url = "http://www.gpo.gov:80/fdsys/pkg/FR-#{date}/mods.xml"
        path = "data/mods/#{date}.xml"
        
        if File.exists?(path)
          puts "skipping #{date}"
          next
        else
          puts "downloading #{date}"
        end
        
        File.open(path, File::WRONLY|File::TRUNC|File::CREAT) do |out|
          open(url) do |remote|
            remote.each_line {|line| out.puts line}
          end
        end
      end
    end
  end
end