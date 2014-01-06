namespace :content do
  namespace :dockets do
    desc "Update regulations.gov docket info"
    task :import => :environment do
      importer = Content::DocketImporter.new
      Entry.find_as_array(["SELECT distinct(regulations_dot_gov_docket_id) FROM entries WHERE publication_date > ?", 4.months.ago]).compact.each do |docket_id|
        puts "importing #{docket_id}..."
        begin
          importer.perform(docket_id)
        rescue StandardError => e
          puts e.message
          puts e.backtrace.join("\n")
          Honeybadger.notify(e)
        end
      end
    end
  end
end
