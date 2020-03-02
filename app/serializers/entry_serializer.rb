class EntrySerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :title, :abstract, :publication_date, :document_number, :presidential_document_type_id, :signing_date, :president_id, :start_page, :executive_order_number, :proclamation_number

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

    #TODO: Readdress this so we're not N+1'ing
    Entry.where(id: entry.id).select(sql).first&.president_id
  end

  attribute :correction do |entry|
    entry.granule_class == 'CORRECT' ||
    entry.correction_of_id ||
    (
      (entry.executive_order_number == 0) || entry.executive_order_number.nil?
    )
  end

  #TODO: Determine whether to index publication date increemnts or use native ES date searching

  attribute :cfr_affected_parts do |entry|
    entry.
      entry_cfr_references.
      map do |entry_cfr_reference|
        entry_cfr_reference.title * EntrySearch::CFR::TITLE_MULTIPLIER + entry_cfr_reference.part
      end.
      uniq
  end

  attribute :agency_ids do |entry|
    entry.
      agency_assignments.
      where("agency_id IS NOT NULL").
      map(&:agency_id).
      uniq
  end

  attribute :topic_ids do |entry|
    entry.
      topic_assignments.
      where("topic_id IS NOT NULL").
      map(&:topic_id).
      uniq
  end

  attribute :section_ids do |entry|
    entry.
      section_assignments.
      where("section_id IS NOT NULL").
      map(&:section_id).
      uniq
  end

  attribute :place_ids do |entry|
    entry.
      place_determinations.
      where("place_id IS NOT NULL").
      map{|place_determinations| place_determinations.place_id || '0'}.
      uniq
  end

  attribute :cited_entry_ids do |entry|
    entry.
      citations.
      where("cited_entry_id IS NOT NULL").
      map(&:cited_entry_id).
      uniq
  end

  attribute :effective_date do |entry|
    entry.effective_date&.date
  end

  attribute :comment_date do |entry|
    entry.comments_close_date&.date
  end

  attribute :accepting_comments_on_regulations_dot_gov do |entry|
    #TODO: Mirroring the definition from entry_index, but this looks like a bug since some comment_url can be nil...
    entry.comment_url != ''
  end

  attribute :small_entity_ids do |entry|
    #TODO: Write spec
    small_entity_ids = entry.
      entry_regulation_id_numbers.
      joins("LEFT OUTER JOIN regulatory_plans ON regulatory_plans.regulation_id_number = entry_regulation_id_numbers.regulation_id_number AND regulatory_plans.current = 1
        LEFT OUTER JOIN regulatory_plans_small_entities ON regulatory_plans_small_entities.regulatory_plan_id = regulatory_plans.id").
      select("regulatory_plans_small_entities.small_entity_id AS small_entity_id").
      uniq.
      map{|x| x.small_entity_id || 0}
  end

  attribute :significant do |entry|
    (
      RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES & entry.regulatory_plans.map(&:priority_category)
    ).present?
  end

  def to_hash #TODO: Extract to Base Serializer since used in Entry and PI
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
