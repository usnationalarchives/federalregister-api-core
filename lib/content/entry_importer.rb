module Content
  class EntryImporter
    include Content::EntryImporter::BasicData
    include Content::EntryImporter::Agencies
    include Content::EntryImporter::CFR
    include Content::EntryImporter::FullXml
    include Content::EntryImporter::LedePhotoCandidates
    include Content::EntryImporter::PageNumber
    include Content::EntryImporter::ReferencedDates
    include Content::EntryImporter::Sections
    include Content::EntryImporter::Topics
    include Content::EntryImporter::Urls
  
    def self.process_all_by_date(date, *attributes)
      if date == 'all'
        dates = Entry.find_as_array(
          :select => "distinct(publication_date) AS publication_date",
          :order => "publication_date"
        )
      elsif date =~ /^>/
        date = Date.parse(date.sub(/^>/, ''))
        dates = Entry.find_as_array(
          :select => "distinct(publication_date) AS publication_date",
          :conditions => {:publication_date => date .. Date.today},
          :order => "publication_date"
        )
      elsif date =~ /^\d{4}$/
        dates = Entry.find_as_array(
          :select => "distinct(publication_date) AS publication_date",
          :conditions => {:publication_date => Date.parse("#{date}-01-01") .. Date.parse("#{date}-12-31")},
          :order => "publication_date"
        )
      else
        dates = [date]
      end
    
      dates.each do |date|
        puts "handling #{date}"
        ModsFile.new(date).document_numbers.each do |document_number|
          importer = EntryImporter.new(:date => date, :document_number => document_number)
          
          if attributes == [:all]
            importer.update_all_provided_attributes
          else
            importer.update_attributes(*attributes)
          end
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
      
      if options[:bulkdata_node]
        @bulkdata_node = options[:bulkdata_node]
      end
    end
    
    def mods_file
      @mods_file ||= ModsFile.new(@date)
    end
    
    def mods_node
      @mods_node ||= mods_file.find_entry_node_by_document_number(@document_number)
    end
    
    def update_all_provided_attributes
      update_attributes(*self.provided)
    end
  
    def update_attributes(*attribute_names)
      attribute_names.each do |attr|
        @entry.send("#{attr}=", self.send(attr))
      end
      @entry.save!
    end
  end
end