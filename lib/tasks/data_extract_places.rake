namespace :data do
  namespace :extract do
    desc "Call out to Yahoo! Placemaker to geocode locations in our entries"
    task :places => :environment do 
      placemaker = Placemaker.new(:application_id => ENV['yahoo_placemaker_api_key'])
      
      Entry.find_in_batches(:conditions => "places_determined_at IS NULL AND abstract IS NOT NULL") do |entry_group|
        entry_group.each do |entry|
          puts "determining places for #{entry.document_number} (#{entry.publication_date})"
          # previous_date = nil
        
          Entry.transaction do
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
              entry.place_determinations.create(:place_id => p.id, :confidence => place.confidence, :string => place.string, :context => context)
            end
          
            entry.places_determined_at = Time.now
            entry.save
          end
        end
      end
    end
  end
end