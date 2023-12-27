module Content
  class ExecutiveOrderImporter

  def self.perform(file_path)
    new.perform(file_path)
  end
           
  def perform(file_path)
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

      begin
        publication_date = Date.parse(eo['publication_date'].try(:strip))
      rescue
        publication_date = nil
      end

      entry = locate_document(eo)

      if entry
        Rails.logger.info("Document #{document_number} found...")
        entry.agency_names = [AgencyName.find_by_name!('Executive Office of the President')]
        attr = {
          :presidential_document_number => eo['executive_order_number'],
          :signing_date => eo['signing_date'].present? ? Date.parse(eo['signing_date']) : nil,
          :executive_order_notes => eo['executive_order_notes'] || eo['disposition_notes'],
        }
        if publication_date && (publication_date < HISTORICAL_EO_CUTOFF_DATE)
          attr.merge!(
            executive_order_notes: eo['disposition_notes'],
            granule_class: "PRESDOCU",
            presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id,
            publication_date: publication_date,
            title: eo['title']
          )
        end

        if eo['citation'].present?
          attr[:citation] = eo['citation'].strip
        end
        entry.update(attr)
        Rails.logger.info("Document #{document_number} updated.")
      else
        Rails.logger.info("Document #{document_number} not found!")
      end
    end
  end

  private

  HISTORICAL_EO_CUTOFF_DATE = Date.new(1993,1,1)
  def locate_document(eo)
    document_number = eo['document_number']

    begin
      publication_date = Date.parse(eo['publication_date'].try(:strip))
    rescue
      publication_date = nil
    end

    if publication_date
      if (publication_date < HISTORICAL_EO_CUTOFF_DATE)
        Entry.find_or_initialize_by(presidential_document_number: eo['presidential_document_number'])
      else
        Entry.find_by_document_number_and_publication_date(document_number.strip, publication_date) || Entry.find_by_document_number(document_number.strip)
      end
    else
      Entry.find_by_document_number(document_number.strip)
    end
  end


  end
end
