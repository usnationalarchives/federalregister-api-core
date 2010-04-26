namespace :content do
  namespace :entry do
    task :cfr => :environment do
      date = ENV['DATE_TO_IMPORT'] || Date.today
      Content::EntryImporter.process_all_by_date(date, :cfr_title, :cfr_part, :section_ids)
    end
  end
end