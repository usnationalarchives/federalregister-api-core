class EntryImporter
  include EntryImporter::CFR
  
  def self.process_all_by_date(date, *attributes)
    if date =~ /^\d{4}$/
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
        importer = EntryImporter.new(date, document_number)
        importer.update_attributes(attributes)
      end
    end
  end
  
  # TODO: optionally pass xml_node
  attr_accessor :date, :document_number, :mods_node
  def initialize(date, document_number, options = {})
    @date = date.is_a?(String) ? Date.parse(date) : date
    @document_number = document_number
    
    options.symbolize_keys!
    if options[:mods_node]
      @mods_node = options[:mods_node]
    else
      @mods_node = ModsFile.new(@date).find_entry_node_by_document_number(@document_number)
    end
    
    @entry = Entry.find_by_document_number(@document_number) || Entry.new(:document_number => @document_number, :publication_date => @date)
  end
  
  def update_all_provided_attributes
    set_attributes(self.provided)
  end
  
  def update_attributes(attribute_names)
    attribute_names.each do |attr|
      @entry.send("#{attr}=", self.send(attr))
    end
    @entry.save!
  end
end
