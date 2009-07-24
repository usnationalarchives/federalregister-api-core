task :extract_dates => :environment do 
  Entry.all(:order => "publication_date DESC", :limit => 100).each do |entry|
    puts "extracting dates for #{entry.document_number}"
    
    puts entry.abstract
    dates = []
    
    PotentialDateExtractor.extract(entry.abstract).each do |potential_date|
      puts " => #{potential_date} [POTENTIAL]"
      date = Chronic.parse(potential_date)#, :now => entry.publication_date)
      if date
        puts " => #{date.to_date} [ACTUAL]"
        dates << date.to_date
      end
    end
    puts "\n\n"
    # dates.uniq.sort.map{|d| puts " => #{d}"}
    
  end
end