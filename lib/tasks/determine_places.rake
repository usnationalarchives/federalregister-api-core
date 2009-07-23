task :determine_places => :environment do 
  placemaker_config = YAML::load(File.open("#{RAILS_ROOT}/config/placemaker.yml"))
  placemaker = Placemaker.new(placemaker_config)
  
  Entry.all(:conditions => "places_determined_at IS NULL", :order => "publication_date").each do |entry|
    puts "determining places for #{entry.document_number}"
    # previous_date = nil
    
    Entry.transaction do
      # clear out existing place determinations
      entry.place_determinations = []
      
      # fetch new place determinations
      places = placemaker.places("#{entry.title} #{entry.abstract}")
      
      places.each do |place|
        p = Place.find_or_create_by_id(place.id)
        p.place_type = place.type
        p.name = place.name
        p.longitude = place.longitude
        p.latitude = place.latitude
        p.save
        
        entry.place_determinations.create(:place_id => p.id, :confidence => place.confidence)
      end
      
      entry.places_determined_at = Time.now
      entry.save
    end
    
    # if previous_date != entry.publication_date
    #   sleep 2
    #   previous_date = entry.publication_date
    # end
    
  end
end