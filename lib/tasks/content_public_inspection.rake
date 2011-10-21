namespace :content do
  namespace :public_inspection do
    desc "Import current public inspection data"
    task :import => :environment do
      Content::PublicInspectionImporter.perform

      Rake::Task["content:public_inspection:reindex"].invoke unless Rails.env == 'development'
    end

    task :import_and_deliver => :environment do
      new_documents = Content::PublicInspectionImporter.perform

      Rake::Task["content:public_inspection:reindex"].invoke unless Rails.env == 'development'

      MailingList::PublicInspectionDocument.active.find_each do |mailing_list|
        begin
          mailing_list.deliver!(new_documents)
        rescue Exception => e
          Rails.logger.warn(e)
          HoptoadNotifier.notify(e)
        end
      end
    end

    task :reindex do
      `bundle exec cap #{RAILS_ENV} sphinx:public_inspection:reindex`
    end
  end
end
