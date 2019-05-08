module Content::ExecutiveOrderImporter
  def self.perform(file_path)
    executive_orders = []
    CSV.foreach(file_path, :headers => :first_row, :encoding => 'windows-1251:utf-8') do |line|
      executive_orders << line.to_hash
    end

    max_known_eo_number = executive_orders.map{|eo| eo['executive_order_number'] }.max
    Entry.scoped(:conditions => ["executive_order_number <= ?", max_known_eo_number]).update_all(:executive_order_number => nil)
    executive_orders.each do |eo|
      document_number = eo['document_number']
      next if document_number.blank?

      puts "Attempting update of #{document_number}..."
      entry = Entry.find_by_document_number(document_number.strip)
      if entry
        puts "Entry found..."
        entry.agency_names = [AgencyName.find_by_name!('Executive Office of the President')]
        attr = {
          :executive_order_number => eo['executive_order_number'],
          :signing_date => eo['signing_date'].present? ? Date.parse(eo['signing_date']) : nil,
          :executive_order_notes => eo['executive_order_notes'],
          :granule_class => "PRESDOCU",
          :presidential_document_type_id => 2
        }
        if eo['citation'].present?
          attr[:citation] = eo['citation'].strip
        end
        entry.update_attributes(attr)
        puts "Entry updated."
      else
        puts "'#{document_number}' not found!"
      end
    end
  end
end
