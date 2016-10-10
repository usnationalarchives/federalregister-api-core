namespace :content do
  namespace :dockets do
    desc "Update regulations.gov docket info"
    task :import => :environment do
      Entry.find_as_array(
        ["SELECT distinct(regulations_dot_gov_docket_id)
          FROM entries WHERE publication_date > ?
          ORDER BY publication_date DESC", 4.months.ago]
      ).compact.each do |docket_id|
        Resque.enqueue(DocketImporter, docket_id)
      end
    end
  end
end
