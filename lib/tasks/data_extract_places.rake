namespace :data do
  namespace :extract do
    desc "Call out to Yahoo! Placemaker to geocode locations in our entries"
    task :places => :environment do 
      date = ENV['DATE'].blank? ? Time.current.to_date : Date.parse(ENV['DATE'])
      
      placemaker = Placemaker.new(:application_id => SECRETS['api_keys']['yahoo_placemaker'])
      
      Entry.find_each(:conditions => ["publication_date = ? AND abstract IS NOT NULL", date]) do |entry|
        puts "determining places for #{entry.document_number} (#{entry.publication_date})"
        # previous_date = nil
    
        next if entry.abstract.blank?
      
        # clear out existing place determinations
        entry.place_determinations = []
      
        # fetch new place determinations
        places = placemaker.places(entry.abstract)
      
        places.each do |place|
          p = Place.find_or_create_by_id(place.id)
          p.place_type = place.type
          p.name = place.name
          p.longitude = place.longitude
          p.latitude = place.latitude
          p.save
        
          context = entry.abstract.match(/\b.{0,100}#{Regexp.escape(place.string)}.{0,100}\b/)[0]
          context = context[0,255]
          entry.place_determinations.create(:place_id => p.id, :confidence => place.confidence, :string => place.string, :context => context)
        end
      
        entry.places_determined_at = Time.now
        entry.save
      end
    end
  end
end
