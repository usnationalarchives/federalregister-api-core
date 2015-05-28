namespace :content do
  namespace :entries do
    namespace :json do
      namespace :compile do
        desc "Compile json for table of contents"
        task :all => %w(
                  daily_toc
                  fr_index
                  pi_toc
                )

        task :daily_toc => :environment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            next unless Issue.should_have_an_issue?(Date.parse(date))

            puts "compiling daily table of contents json for #{date}..."
            XmlTableOfContentsTransformer.perform(date)
          end
        end

        task :fr_index => :environment do
          dates = Content.parse_dates(ENV['DATE'])
          years = dates.map{|d| d.split('-').first}.uniq

          years.each do |year|
            puts "compiling fr_index json for #{year}..."
            FRIndexCompiler.perform(year)
          end
        end

        task :pi_toc => :envrionment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            next unless Issue.should_have_an_issue?(Date.parse(date))

            issue = PublicInspectionIssue.find_by_publication_date(date)
            unless issue && issue.published_at
              puts "no published PI issue for #{date}"
              next
            end

            puts "compiling PI table of contents json for #{date}..."
            TableOfContentsTransformer::PublicInspection::RegularFiling.perform(issue.published_at.to_date)
            TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(issue.published_at.to_date)
          end
        end
      end
    end
  end
end
