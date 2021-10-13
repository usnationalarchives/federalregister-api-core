class EntrySerializer < ApplicationSerializer
  extend Rails.application.routes.url_helpers
  extend RouteBuilder
  extend Routeable

  attributes :id, :title, :abstract, :publication_date, :document_number, :presidential_document_type_id, :signing_date, :president_id, :start_page, :executive_order_number, :proclamation_number

  attribute :agencies do |entry|
    entry.agency_name_assignments.map(&:agency_name).compact.map do |agency_name|
      agency = agency_name.agency
      if agency
        {
          :raw_name  => agency_name.name,
          :name      => agency.name,
          :id        => agency.id,
          :url       => agency_url(agency),
          :json_url  => api_v1_agency_url(agency.id, :format => :json),
          :parent_id => agency.parent_id,
          :slug      => agency.slug
        }
      else
        {
          :raw_name => agency_name.name
        }
      end
    end
  end

  attribute :full_text do |entry|
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
    entry.
      entry_regulation_id_numbers.
      map(&:regulation_id_number).
      uniq
  end

  attribute :docket_id do |entry|
    entry.
      docket_numbers.
      map(&:number).
      uniq
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

    #NOTE: There's a potential performance gain here if this was translated to Ruby
    Entry.where(id: entry.id).select(sql).first&.president_id
  end

  attribute :correction do |entry|
    entry.granule_class == 'CORRECT' ||
    !entry.correction_of_id.nil? ||
    (
      (entry.presidential_document_type_id == PresidentialDocumentType::EXECUTIVE_ORDER.id) &&
      (
        (entry.presidential_document_number == 0) ||
        entry.presidential_document_number.nil?
      )
    )
  end

  attribute :cfr_affected_parts do |entry|
    entry.
      entry_cfr_references.
      map do |entry_cfr_reference|
        entry_cfr_reference.title * Entry.search_klass::CFR::TITLE_MULTIPLIER + (entry_cfr_reference.part || 0)
      end.
      uniq
  end

  attribute :agency_ids do |entry|
    entry.
      agency_assignments.
      select{|x| x.agency_id != nil}.
      map(&:agency_id).
      uniq
  end

  attribute :topic_ids do |entry|
    entry.
      topic_assignments.
      select{|x| x.topic_id != nil}.
      map(&:topic_id).
      uniq
  end

  attribute :section_ids do |entry|
    entry.
      section_assignments.
      select{|x| x.section_id != nil}.
      map(&:section_id).
      uniq
  end

  attribute :place_ids do |entry|
    entry.
      place_determinations.
      select{|x| x.place_id != nil}.
      map{|place_determinations| place_determinations.place_id || '0'}.
      uniq
  end

  attribute :cited_entry_ids do |entry|
    entry.
      citations.
      select{|x| x.cited_entry_id != nil}.
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
    entry.comment_url.present?
  end

  attribute :small_entity_ids do |entry|
    #NOTE: There's likely an indexing performance gain here since this join is expensive and also N+1'ing for each entry.  if we extract this to a custom join called #small_entity_ids and then preload it in the bulk index task.
    small_entity_ids = entry.
      entry_regulation_id_numbers.
      joins("LEFT OUTER JOIN regulatory_plans ON regulatory_plans.regulation_id_number = entry_regulation_id_numbers.regulation_id_number AND regulatory_plans.current = 1
        LEFT OUTER JOIN regulatory_plans_small_entities ON regulatory_plans_small_entities.regulatory_plan_id = regulatory_plans.id").
      select("regulatory_plans_small_entities.small_entity_id AS small_entity_id").
      map{|x| x.small_entity_id || 0}.
      uniq
  end

  attribute :significant do |entry|
    (
      RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES & entry.current_regulatory_plans.map(&:priority_category)
    ).present?
  end

end
