module Content::ExecutiveOrderImporter
  def self.perform(file_path)
    executive_orders = []
    CSV.foreach(
      file_path,
      :headers => :first_row,
      :encoding => 'windows-1251:utf-8',
      :header_converters => lambda do |f|
        val = f.try(:strip).try(:downcase)
      end,
      :skip_blanks => true
    ) do |line|
      if line.to_s.chomp.gsub(',','').present?
        executive_orders << line.to_hash
      end
    end

    max_known_eo_number = executive_orders.map{|eo| eo['executive_order_number'] }.max
    Entry.scoped(
      :conditions => ["presidential_document_type_id = #{PresidentialDocumentType::EXECUTIVE_ORDER.id} AND CAST(presidential_document_number AS UNSIGNED) <= ?", max_known_eo_number]
    ).update_all(:presidential_document_number => nil)
    executive_orders.each do |eo|
      document_number = eo['document_number']
      next if document_number.blank?

      puts "Attempting update of #{document_number}..."

      begin
        publication_date = Date.parse(eo['publication_date'].try(:strip))
      rescue
        publication_date = nil
      end

      if publication_date
        entry = Entry.find_by_document_number_and_publication_date(document_number.strip, publication_date)
      else
        entry = Entry.find_by_document_number(document_number.strip)
      end

      if entry
        puts "Entry found..."
        entry.agency_names = [AgencyName.find_by_name!('Executive Office of the President')]
        attr = {
          :presidential_document_number => eo['executive_order_number'],
          :signing_date => eo['signing_date'].present? ? Date.parse(eo['signing_date']) : nil,
          :executive_order_notes => eo['executive_order_notes'],
          :granule_class => "PRESDOCU",
          :presidential_document_type_id => 2
        }
        if eo['citation'].present?
          attr[:citation] = eo['citation'].strip
        end
        entry.update(attr)
        puts "Entry updated."
      else
        puts "'#{document_number}' not found!"
      end
    end
  end
end
