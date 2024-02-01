namespace :content do
  namespace :entries do
    desc "Reimport entry data from FDSys"
    task :background_reimport => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Sidekiq::Client.enqueue(
          EntryReimporter, date.to_s(:iso), :all,
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
        Sidekiq::Client.enqueue(EntryReimporter, date.to_s(:iso), :citations)
      end
    end

    desc "Recompile pre-compiled Entry and ToC pages"
    task :recompile => [:recompile_all_html, :recompile_all_toc]

    desc "Recompile all pre-compiled Entry pages for a set of dates"
    task :recompile_all_html => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Sidekiq::Client.push(
          'class' => 'IssueReprocessor',
          'args'  => [date.to_s(:iso)],
          'queue' => 'issue_reprocessor'
        )
      end
    end

    desc "Recompile all pre-compiled ToC pages for a set of dates"
    task :recompile_all_toc => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Sidekiq::Client.enqueue(TableOfContentsRecompiler, date.to_s(:iso))
      end
    end

    namespace :presidential_documents do
      desc "Reimport presidential documents (adds fields that weren't originally imported)"
      task :reimport => :environment do

        if ENV['DOCNUM']
          import_presidential_document(Entry.find_by_document_number(ENV['DOCNUM']))
        else
          Entry.scoped(conditions: "granule_class = 'PRESDOCU' AND publication_date > '2000-01-01'").find_each do |entry|
            import_presidential_document(entry)
          end
        end
      end

      def import_presidential_document(entry)
        # supports 'mods' or 'bulkdata'
        import_from = ENV['IMPORT_FROM'] || 'mods'

        puts "reimporting #{entry.document_number} (#{entry.publication_date}) from #{import_from}"

        case import_from
        when 'mods'
          options = {}
        when 'bulkdata'
          return unless entry.has_full_xml?
          options = {bulkdata_node: Nokogiri::XML(open(entry.full_xml_file_path)).root}
        end

        importer_options = {entry: entry}.merge(options)
        Content::EntryImporter.import_document(importer_options, [:presidential_document_type_id, :presidential_document_number, :signing_date, :president_id])
      end
    end
  end
end
