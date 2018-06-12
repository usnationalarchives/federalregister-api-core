namespace :content do
  namespace :entries do
    desc "Reimport entry data from FDSys"
    task :reimport => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Resque.enqueue(
          EntryReimporter, date, :all,
          :force_reload_mods => true,
          :force_reload_bulkdata => true,
          :allow_download_failure => ENV['ALLOW_DOWNLOAD_FAILURE'],
          :tolerate_missing_bulkdata => ENV['TOLERATE_MISSING_BULKDATA']
        )
      end
    end

    desc "Re-extract citations"
    task :reextract_citations => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Resque.enqueue(EntryReimporter, date, :citations)
      end
    end

    desc "Recompile pre-compiled Entry and ToC pages"
    task :recompile => [:recompile_all_html, :recompile_all_toc]

    desc "Recompile all pre-compiled Entry pages for a set of dates"
    task :recompile_all_html => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Resque.enqueue(EntryRecompiler, date)
      end
    end

    desc "Recompile all pre-compiled ToC pages for a set of dates"
    task :recompile_all_toc => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Resque.enqueue(TableOfContentsRecompiler, date)
      end
    end

    namespace :presidential_documents do
      desc "Reimport presidential documents (adds fields that weren't originally imported)"
      task :reimport => :environment do
        # supports 'mods' or 'bulkdata'
        import_from = ENV['IMPORT_FROM'] || 'mods'

        Entry.scoped(:conditions => "granule_class = 'PRESDOCU' AND publication_date > '2000-01-01'").find_each do |entry|
          puts "reimporting #{entry.document_number} (#{entry.publication_date}) from #{import_from}"

          case import_from
          when 'mods'
            options = {}
          when 'bulkdata'
            next unless entry.has_full_xml?
            options = {bulkdata_node: Nokogiri::XML(open(entry.full_xml_file_path)).root}
          end

          importer_options = {entry: entry}.merge(options)
          Content::EntryImporter.new(importer_options).update_attributes(:presidential_document_type_id, :signing_date, :executive_order_number, :proclamation_number)
        end
      end
    end
  end
end
