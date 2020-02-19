class EntrySerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :title, :abstract, :publication_date, :significant, :document_number, :presidential_document_type_id, :document_number, :signing_date, :president_id, :start_page, :executive_order_number, :proclamation_number

  attribute :full_text do |entry|
    #TODO: Consider whether line breaks should be included here
    path = "#{FileSystemPathManager.data_file_path}/documents/full_text/raw/#{entry.document_file_path}.txt"
    if File.file?(path)
      contents = File.read(path)
    end
  end

  attribute :type do |entry|
    if entry.granule_class == 'SUNSHINE'
      'NOTICE'
    else
      entry.granule_class
    end
  end

  attribute :regulation_id_number do |entry|
    entry.entry_regulation_id_numbers.pluck(:regulation_id_number).uniq
  end

  attribute :docket_id do |entry|
    entry.docket_numbers.pluck(:number).uniq
  end

  attribute :signing_date do |entry|
    if entry.granule_class == 'PRESDOCU'
      entry.signing_date || entry.publication_date
    end
  end

  attribute :president_id do |entry|
    sql = <<-SQL
      IF(granule_class = 'PRESDOCU', INTERVAL(DATE_FORMAT(IFNULL(signing_date,DATE_SUB(publication_date, INTERVAL 3 DAY)), '%Y%m%d'),#{President.all.map{|p| p.starts_on.strftime("%Y%m%d")}.join(', ')}), NULL) AS president_id
    SQL

    Entry.where(id: entry.id).select(sql).first&.president_id
  end

  attribute :correction do |entry|
    entry.granule_class == 'CORRECT' ||
    entry.correction_of_id ||
    (
      (entry.executive_order_number == 0) || entry.executive_order_number.nil?
    )
  end

  # attribute :cfr_affected_parts do |entry|
  #   # entry.cfr_references.select(:title, :)
  # end

  #TODO: publication_date_increments

  def to_hash
    data = serializable_hash

    if data[:data].is_a? Hash
      data[:data][:attributes]

    elsif data[:data].is_a? Array
      data[:data].map{ |x| x[:attributes] }

    elsif data[:data] == nil
      nil

    else
      data
    end
  end

end
