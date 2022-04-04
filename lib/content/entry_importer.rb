module Content
  class EntryImporter
    class MissingDocumentNumber < StandardError; end
    class IssueMissingDocumentNumbers < StandardError; end

    # order here determines order of attributes when running :all
    include Content::EntryImporter::BasicData
    include Content::EntryImporter::Agencies
    include Content::EntryImporter::Cfr
    include Content::EntryImporter::FullText
    include Content::EntryImporter::FullXml
    include Content::EntryImporter::RawText
    include Content::EntryImporter::LedePhotoCandidates
    # include Content::EntryImporter::PageNumber
    include Content::EntryImporter::EventDetails
    include Content::EntryImporter::Sections
    include Content::EntryImporter::TopicNames
    include Content::EntryImporter::PresidentialDocumentDetails
    include Content::EntryImporter::Urls
    include Content::EntryImporter::Action
    include Content::EntryImporter::TextCitations

    def self.process_all_by_date(date, *attributes)
      AgencyObserver.disabled = true
      EntryObserver.disabled = true

      dates = Content.parse_dates(date)

      dates.each do |date|
        begin
          process_date(date, *attributes)
        rescue Content::EntryImporter::ModsFile::DownloadError => e
          if ENV['ALLOW_DOWNLOAD_FAILURE']
            puts "...could not download MODS file for #{date}"
          else
            raise e
          end
        end
      end
    end

    def self.process_date(date, *attributes)
      options = attributes.extract_options!
      options.symbolize_keys!

      puts "handling #{date}"
      if date < Date.parse('2000-01-18')
        process_without_bulkdata(date, options, *attributes)
      else
        begin
          docs_and_nodes = BulkdataFile.new(date, options[:force_reload_bulkdata]).document_numbers_and_associated_nodes
        rescue Content::EntryImporter::BulkdataFile::DownloadError => e
          if ENV['TOLERATE_MISSING_BULKDATA'] || options[:tolerate_missing_bulkdata]
            process_without_bulkdata(date, options, *attributes)
            return
          elsif ENV['ALLOW_DOWNLOAD_FAILURE'] || options[:allow_download_failure]
            puts "...could not download bulkdata file for #{date}"
            return
          else
            raise e
          end
        end

        mods_doc_numbers = ModsFile.new(date, options[:force_reload_mods]).document_numbers

        raise IssueMissingDocumentNumbers, "No documents numbers present in MODS file for #{date}." unless mods_doc_numbers.present?

        document_numbers_missing_from_bulk_data = (mods_doc_numbers - docs_and_nodes.map{|doc, node| doc})
        if document_numbers_missing_from_bulk_data.present?
          notify_of_missing_document(:bulkdata, date, document_numbers_missing_from_bulk_data)
        end
        document_numbers_missing_from_bulk_data.each do |document_number|
          import_document(
            options.merge(:date => date, :document_number => document_number),
            attributes
          )
        end

        document_numbers_missing_from_mods = (docs_and_nodes.map{|doc, node| doc} - mods_doc_numbers)
        if document_numbers_missing_from_mods.present?
          notify_of_missing_document(:mods, date, document_numbers_missing_from_mods)
        end
        docs_and_nodes.each do |document_number, bulkdata_node|
          if mods_doc_numbers.include?(document_number)
            import_document(
              options.merge(
                :date => date, :document_number => document_number,
                :bulkdata_node => bulkdata_node
              ),
              attributes
            )
          end
        end

        remove_extraneous_documents(date, mods_doc_numbers)
        issue = create_issue(date)
        begin
          IssueUpdater.new(issue, ModsFile.new(date, options[:force_reload_mods]), BulkdataFile.new(date, options[:force_reload_bulkdata])).process
        rescue StandardError => e
          puts e.message
          puts e.backtrace.join("\n")
          Honeybadger.notify(e)
        end
        mark_corrected_documents_for_reindex(issue)
      end
    end

    def self.mark_corrected_documents_for_reindex(issue)
      entry_ids = issue.
        entries.
        where.not(correction_of_id: nil).
        pluck(:correction_of_id)
      if entry_ids.present?
        EntryChange.upsert_all(entry_ids.map{|id| {entry_id: id} })
      end
    end

    def self.notify_of_missing_document(type, date, document_numbers)
      case type
      when :bulkdata
        error_class = "Missing Document Numbers in bulkdata"
        error = "'#{document_numbers}' (#{date}) in MODS but not in bulkdata"
      when :mods
        error_class = "Missing Document Numbers in MODS"
        error = "'#{document_numbers}' (#{date}) in bulkdata but not in MODS"
      end

      Rails.logger.warn(error)
      Honeybadger.notify(
        :error_class   => error_class,
        :error_message => error
      )
    end

    def self.import_document(importer_options, attributes)
      importer = EntryImporter.new(importer_options)
      attributes = attributes.map(&:to_sym)

      if importer_options[:except]
        attributes = importer.provided - importer_options[:except].map(&:to_sym)
      end

      if (attributes == [:all]) || (attributes == ['all'])
        importer.update_all_provided_attributes
      else
        importer.update_attributes(*attributes)
      end
    end

    def self.remove_extraneous_documents(date, mods_doc_numbers)
      Entry.where(publication_date: date).each do |entry|
        unless mods_doc_numbers.include?(entry.document_number)
          entry.destroy
        end
      end
    end

    def self.create_issue(date)
      if Entry.published_on(date).count > 0
        issue = Issue.find_by_publication_date(date) || Issue.new(:publication_date => date)
        issue.save!
        issue
      end
    end

    def self.process_without_bulkdata(date, options, *attributes)
      ModsFile.new(date, options[:force_reload_mods]).document_numbers.each do |document_number|
        importer = EntryImporter.new(
          options.except(:force_reload_mods).merge(:date => date, :document_number => document_number)
        )

        attributes = attributes.map(&:to_sym)
        if options[:except]
          attributes = importer.provided - options[:except].map(&:to_sym)
        end

        if (attributes == [:all]) || (attributes == ['all'])
          importer.update_all_provided_attributes
        else
          importer.update_attributes(*attributes)
        end
      end
    end

    attr_accessor :date, :document_number, :bulkdata_node, :entry
    def initialize(options = {})
      options.symbolize_keys!
      if options[:entry]
        @entry = options[:entry]
        @date = @entry.publication_date
        @document_number = @entry.document_number
      else
        @date = options[:date].is_a?(String) ? Date.parse(options[:date]) : options[:date]
        raise "must provide a date if no entry" if @date.nil?
        @document_number = options[:document_number] or raise "must provide a document number if no entry"
        @entry = Entry.where("document_number = ? AND publication_date = ?", @document_number, @date.to_s(:iso)).first ||
          Entry.new(:document_number => @document_number)
        @entry.publication_date = @date
      end
      @force_reload_mods = options[:force_reload_mods]

      if options[:bulkdata_node]
        @bulkdata_node = options[:bulkdata_node]
      end
    end

    def mods_file
      @mods_file ||= ModsFile.new(@date, @force_reload_mods)
    end

    def mods_node
      @mods_node ||= mods_file.find_entry_node_by_document_number(@document_number)
    end

    def update_all_provided_attributes
      update_attributes(*self.provided)
    end

    def verbose?
      ENV['VERBOSE'] == '1'
    end

    def debug(text)
      puts "**** " + text if verbose?
    end

    def update_attributes(*attribute_names)
      raise "No attributes provided to import for #{date}" unless attribute_names.present?

      attribute_names.each do |attr|
        puts "handling '#{attr}' for '#{document_number}' (#{date})" if verbose?
        @entry.send("#{attr}=", self.send(attr))
      end
      @entry.save!
    end
  end
end
