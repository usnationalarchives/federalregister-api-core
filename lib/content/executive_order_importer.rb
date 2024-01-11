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

    count = 0
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

        signing_date = eo['signing_date'].present? ? Date.parse(eo['signing_date']) : nil
        not_received_for_publication = (eo['publication_date'] == 'not_received_for_publication')

        attr = {
          :presidential_document_number => eo['executive_order_number'],
          :signing_date => signing_date,
        }.tap do |attrs|
          president = President.find_by_identifier(eo['president'])
          if president
            attrs.merge!(:president_id => president.id)
          end
        end

        if reasonable_date_range.exclude? signing_date
          # ie delete the signing_date if it appears unreasonable
          attr.delete(:signing_date)
        end

        #   not_received_for_publication
        integer_coerced_eo_number = eo['executive_order_number'].gsub(/\D/, '').to_i
        if eo['executive_order_number'] && (integer_coerced_eo_number < HISTORICAL_EO_NUMBER_CUTOFF)
          attr.merge!(
            executive_order_notes: eo['disposition_notes'],
            granule_class: "PRESDOCU",
            presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id,
            publication_date: publication_date,
            title: eo['title'],
          ).tap do |attr|
            if not_received_for_publication
              attr.merge!(not_received_for_publication: not_received_for_publication)
            end
          end
        end

        if reasonable_date_range.exclude? publication_date
          attr.delete(:publication_date)
        end

        if eo['citation'].present?
          attr[:citation] = eo['citation'].strip
        end
        entry.update(attr)
        count += 1
        puts "#{count} EOs updated..."
        Rails.logger.info("EO #{eo['executive_order_number']} updated.")
      else
        Rails.logger.info("EO #{eo['executive_order_number']} not found!")
      end
    end
  end

  private

  def reasonable_date_range
    (Date.new(1900,1,1)..Date.current)
  end

  HISTORICAL_EO_NUMBER_CUTOFF = 12890 #ie published on 1994-01-05
  def locate_document(eo)
    document_number = eo['document_number']

    begin
      publication_date = Date.parse(eo['publication_date'].try(:strip))
    rescue
      publication_date = nil
    end

    if document_number.present?
      if publication_date
        Entry.find_by_document_number_and_publication_date(document_number.strip, publication_date) || Entry.find_by_document_number(document_number.strip)
      else
        Entry.find_by_document_number(document_number.strip)
      end
    elsif eo['executive_order_number']
      Entry.find_or_initialize_by(
        presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id,
        presidential_document_number: eo['executive_order_number']
      )
    end
  end

  end
end
