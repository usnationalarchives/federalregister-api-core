namespace :content do
  namespace :dockets do
    desc "Update regulations.gov docket info"
    task :import => :environment do
      participating_agency_ids = DocketImporter.participating_agency_ids
      participating_agencies_query = participating_agency_ids.map do |id|
        "regulations_dot_gov_docket_id LIKE '#{id}\\_%' OR regulations_dot_gov_docket_id LIKE '#{id}-%'"
      end.join(' OR ')

      Entry.find_as_array(
        ["SELECT distinct(regulations_dot_gov_docket_id), publication_date
          FROM entries
          WHERE publication_date > ?
            AND (#{participating_agencies_query})
          ORDER BY publication_date DESC", 4.months.ago]
      ).compact.each do |docket_id|
        Sidekiq::Client.enqueue(DocketImporter, docket_id, false)
      end
    end
  end
end
