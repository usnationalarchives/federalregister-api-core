namespace :content do
  namespace :disposition_tables do
    namespace :import do
      desc "Import Executive Order data for years before bulkdata is available"
      task :pre_bulkdata => :environment do
        ['1993-clinton', '1994', '1995', '1996', '1997', '1998', '1999'].each do |year_and_president|
          Content::DispositionTableImporter.new(year_and_president).import
        end
      end
    end
  end
end
