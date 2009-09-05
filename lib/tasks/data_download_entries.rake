namespace :data do
  namespace :download do
    task :entries => :environment do
      require "open-uri"
    
      date = ENV['DATE_TO_IMPORT'].blank? ? Date.today : Date.parse(ENV['DATE_TO_IMPORT'])
    
      url = "http://www.gpo.gov:80/fdsys/pkg/FR-#{date.to_s(:db)}/mods.xml"
      path = "data/mods/#{date.to_s(:db)}.xml"
    
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