module Content
  class EntryImporter
    class MissingDocumentNumber < StandardError; end

    # order here determines order of attributes when running :all
    include Content::EntryImporter::BasicData
    include Content::EntryImporter::Agencies
    include Content::EntryImporter::CFR
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
    include Content::EntryImporter::RegulationsDotGovAttributes
    include Content::EntryImporter::Action
    include Content::EntryImporter::TextCitations

    def self.process_all_by_date(date, *attributes)
      AgencyObserver.disabled = true
      EntryObserver.disabled = true
      options = attributes.extract_options!
      options.symbolize_keys!


      dates = Content.parse_dates(date)

      dates.each do |date|
        begin
          puts "handling #{date}"
          if date < '2000-01-01'
            process_without_bulkdata(date, options, *attributes)
          else
            begin
              docs_and_nodes = BulkdataFile.new(date, options[:force_reload_bulkdata]).document_numbers_and_associated_nodes
            rescue Content::EntryImporter::BulkdataFile::DownloadError => e
              if ENV['TOLERATE_MISSING_BULKDATA']
                process_without_bulkdata(date, options, *attributes)
                next
              elsif ENV['ALLOW_DOWNLOAD_FAILURE']
                puts "...could not download bulkdata file for #{date}"
                next
              else
                raise e
              end
            end

            mods_doc_numbers = ModsFile.new(date, options[:force_reload_mods]).document_numbers

            (mods_doc_numbers - docs_and_nodes.map{|doc, node| doc}).each do |document_number|
              error = "'#{document_number}' (#{date}) in MODS but not in bulkdata"
              Rails.logger.warn(error)
              Honeybadger.notify(
                :error_class   => "Missing Document Number in bulkdata",
                :error_message => error
              )

              importer = EntryImporter.new(options.merge(:date => date, :document_number => document_number))
              attributes = attributes.map(&:to_sym)
              if options[:except]
                attributes = importer.provided - options[:except].map(&:to_sym)
              end

              if attributes == [:all]
                importer.update_all_provided_attributes
              else
                importer.update_attributes(*attributes)
              end
            end

            docs_and_nodes.each do |document_number, bulkdata_node|
              if mods_doc_numbers.include?(document_number)
                importer = EntryImporter.new(options.merge(:date => date, :document_number => document_number, :bulkdata_node => bulkdata_node))

                attributes = attributes.map(&:to_sym)
                if options[:except]
                  attributes = importer.provided - options[:except].map(&:to_sym)
                end

                if attributes == [:all]
                  importer.update_all_provided_attributes
                else
                  importer.update_attributes(*attributes)
                end
              else
                error = "'#{document_number}' (#{date}) in bulkdata but not in MODS"
                Rails.logger.warn(error)
                Honeybadger.notify(
                  :error_class   => "Missing Document Number in MODS",
                  :error_message => error
                )
              end
            end
          end
        rescue Content::EntryImporter::ModsFile::DownloadError => e
          if ENV['ALLOW_DOWNLOAD_FAILURE']
            puts "...could not download MODS file for #{date}"
          else
            raise e
          end
        end
      end
    end

    def self.process_without_bulkdata(date, options, *attributes)
      ModsFile.new(date, options[:force_reload_mods]).document_numbers.each do |document_number|
        importer = EntryImporter.new(options.merge(:date => date, :document_number => document_number))

        attributes = attributes.map(&:to_sym)
        if options[:except]
          attributes = importer.provided - options[:except].map(&:to_sym)
        end

        if attributes == [:all]
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
        @entry = Entry.find_by_document_number(@document_number) || Entry.new(:document_number => @document_number, :publication_date => @date)
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
      attribute_names.each do |attr|
        puts "handling '#{attr}' for '#{document_number}' (#{date})" if verbose?
        @entry.send("#{attr}=", self.send(attr))
      end
      @entry.save!
    end
  end
end
