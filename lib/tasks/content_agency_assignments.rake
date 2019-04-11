namespace :content do
  namespace :agency_assignments do
    desc "recalculate denormalized agency_assignments and agency.entries_count"
    task :recalculate => :environment do
      begin
        AgencyAssignment.recalculate!
      rescue StandardError => e
        puts e.message
        puts e.backtrace.join("\n")
        Honeybadger.notify(e)
      end
    end
  end
end
