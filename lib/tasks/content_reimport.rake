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

    desc "Update notice types based on already-downloaded bulk XML"
    task :update_notice_types => :environment do
      bad_entries = []
      Entry.where("publication_date >= '2000-01-01'").find_each do |entry|
        begin
          bulkdata_node     = Nokogiri::XML(open(entry.full_xml_file_path)).root
          priact_node       = bulkdata_node.css('PRIACT P').first
          subject_node_text = bulkdata_node.css('PREAMB SUBJECT')&.text

          if priact_node || Content::EntryImporter::SornDetails::SUNSHINE_ACT_SUBJECT_REGEX.match?(subject_node_text)
            attrs = ["notice_type_id"].tap do |attrs|
              if priact_node
                attrs << "system_of_records"
              end
            end

            importer = Content::EntryImporter.new(
              entry: entry,
              bulkdata_node: bulkdata_node
            )
            importer.update_attributes(*attrs)
          end
        rescue StandardError => e
          bad_entries << entry
        end
      end

      ElasticsearchIndexer.reindex_modified_entries
      if bad_entries.present?
        puts "The following document numbers could not be reimported:"
        puts bad_entries.map(&:document_number).join(' ')
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
