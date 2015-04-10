namespace :bulk_import do

  desc "Parse and output bulk xml"
  task :parse_table_of_contents_xml => :environment do
    TableOfContentsTransformer.new.process(date)
  end

end