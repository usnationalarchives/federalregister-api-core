module Content
  class ExecutiveOrderImporter

  def self.perform(file_path, log_differences_only=false)
    new.perform(file_path, log_differences_only)
  end
           
  def perform(file_path, log_differences_only=false)
    @log_differences_only = log_differences_only
    if log_differences_only
      differences = []
    end
    current_time = Time.current

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
      
      entry = locate_document(eo) # NOTE: The embedded assumption is we won't create new EO entries via this importer unless they are not available via the govinfo APIs

      if entry
        Rails.logger.info("Document #{document_number} found...")
        entry.agency_names = [AgencyName.find_by_name!('Executive Office of the President')]

        signing_date = eo['signing_date'].present? ? Date.parse(eo['signing_date']) : nil

        not_received_for_publication = ['not_received_in_time_for_publication', 'not_received_for_publication'].any?{|x| eo['publication_date'] == x}

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

        integer_coerced_eo_number = eo['executive_order_number'].gsub(/\D/, '').to_i
        if eo['executive_order_number'] && (integer_coerced_eo_number < HISTORICAL_EO_NUMBER_CUTOFF)
          if log_differences_only
            next #ie don't log diffs for older EOs we definitely don't have via govinfo APIs
          end

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

        if eo['citation'].present? && !not_received_for_publication
          attr[:citation] = eo['citation'].strip
        end

        if log_differences_only          
          attribute_diffs = []
          row = DIFF_COLUMNS.each_with_object([]) do |(column_name, column_type), columns|
            per_nara = eo[column_name.to_s]
            columns << per_nara

            if column_type == :date
              per_fr = entry[column_name].try(:to_s, :iso)
            else
              if entry.id?
                per_fr = entry[column_name]
              else
                per_fr = nil
              end
            end
            columns << per_fr
            if entry.id? && (per_nara.try(:upcase) != per_fr.try(:upcase)) #ignore casing differences
              attribute_diffs << column_name
            end
          end
          
          if entry.id?
            row << attribute_diffs.join(', ')
          else
            row << "missing from FR"
          end

          Rails.logger.info(row)
          differences << row
        else
          entry.assign_attributes(attr)
          if entry.changed?
            entry.updated_at = current_time
            entry.save
          end
          Rails.logger.info("EO #{eo['executive_order_number']} updated.")
        end
      else
        Rails.logger.info("EO #{eo['executive_order_number']} not found!")
      end
      count += 1
      puts "#{count} EOs processed..."
    end

    if log_differences_only
      CSV.open(diff_file_path, 'w') do |csv|
        headers = DIFF_COLUMNS.keys.each_with_object([]) do |column, headers|
          headers << "#{column}_per_nara"
          headers << "#{column}_per_fr"
        end
        headers << "attributes_with_differences"
        csv << headers

        differences.each { |row| csv << row }
      end
    end
  end

  private
  
  attr_reader :log_differences_only

  DIFF_COLUMNS = {
    executive_order_number: :string,
    publication_date:       :date,
    signing_date:           :date,
    title:                  :string,
  }

  def diff_file_path
    "data/efs/eo_differences_#{Date.current.to_s(:iso)}.csv"
  end

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

    if document_number.present? # We're using the presence of a document number as a proxy for whether the document number is available via govinfo since the document number was not available in the NARA disposition tables
      if publication_date
        Entry.find_by_document_number_and_publication_date(document_number.strip, publication_date) || Entry.find_by_document_number(document_number.strip)
      else
        Entry.find_by_document_number(document_number.strip)
      end
    elsif eo['executive_order_number'] && (eo['executive_order_number'].gsub(/\D/, '').to_i < HISTORICAL_EO_NUMBER_CUTOFF)
      Entry.find_or_initialize_by(
        presidential_document_type_id: PresidentialDocumentType::EXECUTIVE_ORDER.id,
        presidential_document_number: eo['executive_order_number']
      )
    end
  end

  end
end
