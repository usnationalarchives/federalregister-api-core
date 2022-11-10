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
            date = date.is_a?(String) ? Date.parse(date) : date
            next unless Issue.should_have_an_issue?(date)

            puts "compiling daily table of contents json for #{date}..."
            Content::TableOfContentsCompiler.perform(date)
          end
        end

        task :fr_index => :environment do
          dates = Content.parse_dates(ENV['DATE'])
          years = dates.map{|d| d.is_a?(String) ? Date.parse(d).year : d.year}.uniq

          years.each do |year|
            # we don't have FR index before 2013
            next unless year >= 2013

            puts "compiling fr_index json for #{year}..."
            FrIndexCompiler.perform(year)
            FrIndexAgencyCompiler.perform(year)
          end
        end

        task :pi_toc => :environment do
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

      namespace :recompile do
        task :daily_toc => :environment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            date = date.is_a?(String) ? Date.parse(date) : date
            next unless Issue.should_have_an_issue?(date)

            Sidekiq::Client.enqueue(TableOfContentsRecompiler, date.to_s(:iso))
          end
        end

        task :pi_toc => :environment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            date = date.is_a?(String) ? Date.parse(date) : date
            next unless Issue.should_have_an_issue?(date)

            issue = PublicInspectionIssue.find_by_publication_date(date)
            unless issue && issue.published_at
              puts "no published PI issue for #{date}"
              next
            end

            Sidekiq::Client.enqueue(PublicInspectionTableOfContentsRecompiler, date.to_s(:iso))
          end
        end

        task :fr_index => :environment do
          dates = Content.parse_dates(ENV['DATE'])
          years = dates.map{|d| d.is_a?(String) ? Date.parse(d).year : d.year}.uniq

          years.each do |year|
            Sidekiq::Client.enqueue(FrIndexRecompiler, year)
          end
        end
      end
    end
  end
end
