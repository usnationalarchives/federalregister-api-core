class EntrySerializer < ApplicationSerializer
  extend Rails.application.routes.url_helpers
  extend RouteBuilder
  extend Routeable

  attributes :id, :title, :abstract, :action, :dates, :document_number,  :end_page, :executive_order_notes, :executive_order_number, :presidential_document_type_id, :start_page, :executive_order_number, :presidential_document_number, :proclamation_number, :toc_doc, :toc_subject, :volume

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

  attribute :agency_names do |entry|
    entry.agency_names.compact.map{|a| a.agency.try(:name) || a.name}
  end

  attribute :body_html_url do |entry|
    entry_full_text_url(entry)
  end

  attribute :citation do |e|
    e.start_page && e.start_page.to_i > 0 ? e.citation : nil
  end

  attribute :comments_close_on do |e|
    e.comments_close_on&.to_s(:iso)
  end

  attribute :comment_url do |e|
    e.calculated_comment_url
  end

  attribute :cfr_references do |entry|
    entry.entry_cfr_references.sort_by{|x| [x.title.to_i, x.part.to_i] }.map do |cfr_reference|
      citation_url = if cfr_reference.chapter.present? && cfr_reference.part.present?
        select_cfr_citation_url(entry.publication_date, cfr_reference.title, cfr_reference.part, nil)
      else
        nil
      end

      {
        :title        => cfr_reference.title,
        :part         => cfr_reference.part,
        :chapter      => cfr_reference.chapter,
        :citation_url => citation_url,
      }
    end
  end

  attribute :disposition_notes do |e|
    e.executive_order_notes
  end

  attribute :entry_type do |e|
    e.entry_type
  end

  attribute :full_text do |entry|
    path = "#{FileSystemPathManager.data_file_path}/documents/full_text/raw/#{entry.document_file_path}.txt"
    if File.file?(path)
      contents = File.read(path)
    end
  end

  attribute :full_text_xml_url do |e|
    entry_xml_url(e) if e.should_have_full_xml?
  end

  attribute :html_url do |e|
    entry_url(e)
  end

  attribute :images do |entry|
    extracted_graphics = entry.extracted_graphics

    # we have two types of graphics possible, gpo_graphics being the newest
    if extracted_graphics.present?
      graphics = extracted_graphics
    else
      graphics = entry.processed_gpo_graphics
    end

    if graphics.present?
      graphics.inject({}) do |hsh, graphic|
        # gpo graphics must have an xml identifier or else we don't want to expose them via the API
        if graphic.class == GpoGraphic && graphic.xml_identifier.blank?
          hsh
        else
          identifier = graphic.class == GpoGraphic ? graphic.xml_identifier : graphic.identifier

          hsh[identifier] = graphic.graphic.styles.inject({}) do |hsh, style|
            type, paperclip_style = style
            # expose the :original_png style as simply :original
            renamed_type = type == :original_png ? :original : type

            url = paperclip_style.attachment.send(:url, type).tap do |url|
              if EntryApiRepresentation::GRAPHIC_CONTENT_TYPES_FOR_COERCION.include? graphic.graphic_content_type
                url = url.gsub!(/\.png/,'.gif')
              end
            end

            hsh[renamed_type] = url
            hsh
          end

          hsh
        end
      end
    else
      {}
    end
  end

  attribute :json_url do |e|
    api_v1_document_url(
      e.document_number,
      :publication_date => e.publication_date.to_s(:iso),
      :format           => :json
    )
  end

  attribute :mods_url do |e|
    e.source_url(:mods)
  end

  attribute :page_length do |e|
    e.human_length
  end

  attribute :pdf_url do |e|
    e.source_url('pdf')
  end

  attribute :public_inspection_pdf_url do |e|
    e.public_inspection_document.try(:pdf).try(:url)
  end

  attribute :president do |entry|
    president = entry.president
    if president
      {:name => president.full_name, :identifier => president.identifier}
    end
  end

  attribute :raw_text_url do |e|
    entry_raw_text_url(e)
  end

  attribute :raw_text_updated_at do |document|
    document.raw_text_updated_at&.utc&.iso8601
  end

  attribute :type do |entry|
    if entry.granule_class == 'SUNSHINE'
      'NOTICE'
    else
      entry.granule_class
    end
  end

  attribute :regulations_dot_gov_info do |entry|
    vals = {}

    if entry.regulations_dot_gov_document_id
      vals.merge!(:document_id => entry.regulations_dot_gov_document_id)
    end

    if entry.comment_count
      vals.merge!(comments_count: entry.comment_count)
    end

    if entry.regulations_dot_gov_agency_id
      vals.merge!(:agency_id => entry.regulations_dot_gov_agency_id)
    end

    docket = entry.docket
    if docket
      docket_info = {
        :docket_id => docket.id,
        :regulation_id_number => docket.regulation_id_number,
        :title => docket.title,
        :comments_url => regulations_dot_gov_docket_comments_url(docket.id),
        :supporting_documents_count => docket.docket_documents_count,
        :supporting_documents => docket.docket_documents.sort_by(&:id).reverse[0..9].map do |doc|
          {
            :title => doc.title,
            :document_id => doc.id
          }
        end,
      }

      docket_metadata = docket.metadata.except("Keyword(s)")
      docket_info.merge!(metadata: docket_metadata)

      if docket.regulation_id_number.present?
        regulatory_plan = RegulatoryPlan.current.find_by_regulation_id_number(docket.regulation_id_number)
        if regulatory_plan
          docket_info.deep_merge!(
            :regulatory_plan => {
              html_url: regulatory_plan_url(regulatory_plan),
              title: regulatory_plan.title
            }
          )
        end
      end
    end

    if docket_info
      vals.deep_merge!(docket_info)
    end

    vals
  end

  attribute :regulation_id_number do |entry|
    entry.
      entry_regulation_id_numbers.
      map(&:regulation_id_number).
      uniq
  end

  attribute :regulation_id_numbers do |e|
    e.entry_regulation_id_numbers.map{|r| r.regulation_id_number}
  end

  attribute :regulations_dot_gov_url do |e|
    e.regulations_dot_gov_url
  end

  attribute :regulation_id_number_info do |entry|
    values = entry.entry_regulation_id_numbers.map do |e_rin|
      regulatory_plan = e_rin.current_regulatory_plan
      if regulatory_plan
        regulatory_plan_info = {
          :xml_url => regulatory_plan.source_url(:xml),
          :issue => regulatory_plan.issue,
          :title => regulatory_plan.title,
          :priority_category => regulatory_plan.priority_category,
          :html_url => regulatory_plan_url(regulatory_plan)
        }
      end
      [e_rin.regulation_id_number, regulatory_plan_info]
    end

    Hash[*values.flatten]
  end

  attribute :docket_id do |entry|
    entry.
      docket_numbers.
      map(&:number).
      uniq
  end

  attribute :signing_date do |entry|
    entry.signing_date&.to_s(:iso) 
  end

  attribute :president_id do |entry|
    if entry.granule_class == 'PRESDOCU'
      #NOTE: There's a potential performance gain here if this was translated to Ruby
      sql = <<-SQL
        IF(granule_class = 'PRESDOCU', INTERVAL(DATE_FORMAT(IFNULL(signing_date,DATE_SUB(publication_date, INTERVAL 3 DAY)), '%Y%m%d'),#{President.all.map{|p| p.starts_on.strftime("%Y%m%d")}.join(', ')}), NULL) AS president_id
      SQL

      Entry.where(id: entry.id).select(sql).first&.president_id
    end
  end

  attribute :publication_date  do |document|
    document.publication_date&.to_s(:iso) 
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

  attribute :correction_of do |e|
    api_v1_document_url(e.correction_of.document_number, :format => :json) if e.correction_of
  end

  attribute :corrections do |entry|
    entry.corrections.map{|c| api_v1_document_url(c.document_number, :format => :json)}
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

  attribute :effective_on do |entry|
    entry.effective_on&.to_s(:iso) 
  end

  attribute :effective_date do |entry|
    entry.effective_date&.date&.to_s(:iso)
  end

  attribute :comment_date do |entry|
    entry.comments_close_date&.date&.to_s(:iso)
  end

  attribute :accepting_comments_on_regulations_dot_gov do |entry|
    entry.comment_url.present?
  end

  attribute :small_entity_ids do |entry|
    BatchLoader.for(entry.id).batch do |ids, loader|
      EntryRegulationIdNumber.
        where(entry_id: ids).
        joins("LEFT OUTER JOIN regulatory_plans ON regulatory_plans.regulation_id_number = entry_regulation_id_numbers.regulation_id_number AND regulatory_plans.current = 1
          LEFT OUTER JOIN regulatory_plans_small_entities ON regulatory_plans_small_entities.regulatory_plan_id = regulatory_plans.id").
        pluck(Arel.sql("distinct entry_regulation_id_numbers.entry_id, regulatory_plans_small_entities.small_entity_id AS small_entity_id")).
        each_with_object({}) do |(entry_id, small_entity_id), hsh|
          hsh[entry_id] ||= []
          hsh[entry_id] << small_entity_id
        end.
        each do |entry_id, small_entity_ids|
          loader.call(entry_id, small_entity_ids)
        end
    end
  end

  attribute :significant do |entry|
    current_regulatory_plans = entry.current_regulatory_plans

    if current_regulatory_plans.present?
      (
        RegulatoryPlan::SIGNIFICANT_PRIORITY_CATEGORIES &
        current_regulatory_plans.map(&:priority_category)
      ).present?
    end
  end

  attribute :subtype do |e|
    e.presidential_document_type.try(:name)
  end

  attribute :topics do |e|
    e.topics.map{|x| x.try(:name)}.compact
  end

end
