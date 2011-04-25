namespace :content do
  namespace :agency_assignments do
    desc "recalculate denormalized agency_assignments and agency.entries_count"
    task :recalculate => :environment do
      AgencyAssignment.recalculate!
    end
  end
end
