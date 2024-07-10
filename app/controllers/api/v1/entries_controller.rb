class Api::V1::EntriesController < ApiController

  def index
    respond_to do |wants|
      cache_for 1.day

      wants.json do
        fields = specified_fields || EntrySerializer.default_index_fields_json
        find_options = EntrySerializer.find_options_for(fields)

        search = entry_search(deserialized_params, fields)

        render_search(search, find_options, params[:metadata_only]) do |result|
          entry_data(result, fields)
        end
      end

      wants.csv do
        fields = specified_fields || EntrySerializer.default_index_fields_csv
        find_options = EntrySerializer.find_options_for(fields)

        search = entry_search(deserialized_params, fields)
        filename = search.summary.gsub(/\W+/, '_').sub(/_$/,'').downcase
        entries = search.results(find_options)
        render_csv(entries, fields, filename)
      end

      wants.rss do
        fields = EntrySerializer.default_index_fields_rss
        find_options = EntrySerializer.find_options_for(fields)

        search = entry_search(
          deserialized_params.merge(order: 'newest', per_page: 200),
          fields
        )
        documents = search.results(find_options)
        render_rss(documents, "Federal Register #{search.summary}")
      end
    end
  end

  def facets
    field_facets = %w(agency topic section type subtype)
    date_facets = %w(daily weekly monthly quarterly yearly)
    raise ActiveRecord::RecordNotFound unless (field_facets + date_facets).include?(params[:facet])

    respond_to do |wants|
      cache_for 1.day
      search = Entry.search_klass.new(deserialized_params)

      if search.valid?
        if date_facets.include?(params[:facet])
          search_result = search.date_distribution(:period => params[:facet].to_sym)
        else
          search_result = search.send("#{params[:facet]}_facets")
        end
      end

      wants.json do
        if search_result
          if date_facets.include?(params[:facet])
            results = search_result.results
          else
            results = search_result.each_with_object(Hash.new) do |facet, hsh|
              hsh[facet.identifier] = {
                :count => facet.count,
                :name => facet.name
              }
            end
          end

          render_json_or_jsonp(results)
        else
          render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
        end
      end
    end
  end

  def autocomplete_suggestions
    respond_to do |wants|
      cache_for 1.day
      wants.json do
        render_json_or_jsonp(EsEntrySearch.autocomplete(params[:conditions][:term]))
      end
    end
  end

  def search_details
    search = entry_search(deserialized_params)

    if search.valid?
      render_json_or_jsonp(
        :suggestions => search_suggestions(search),
        :filters => search_filters(search)
      )
    else
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
    end
  end

  CSV_SEARCH_RESULT_LIMIT = 200
  def show
    respond_to do |wants|
      wants.json do
        cache_for 1.day

        fields = specified_fields || EntrySerializer.default_show_fields_json
        if params[:id] =~ /FR/
          fields = fields + [:citation]
        end
        find_options = EntrySerializer.find_options_for(fields + [:document_number])

        render_one_or_more(Entry, params[:id], find_options.merge(publication_date: params[:publication_date])) do |entry|
          entry_data(entry, fields)
        end
      end
      wants.csv do
        fields = specified_fields || EntrySerializer.default_show_fields_csv
        document_numbers = params[:id].split(',')
        entries = EsEntrySearch.new(
          conditions: {document_numbers: document_numbers},
          per_page: CSV_SEARCH_RESULT_LIMIT
        ).results

        filename = 'federal_register'
        render_csv(entries, fields, filename)
      end
    end
  end

  private

  #NOTE: Thinking Sphinx v3 is much stricter about types and will throw errors if a string value like "1" is passed in lieu of its integer counterpart
  BOOLEAN_PARAMS_NEEDING_DESERIALIZATION = [
    :accepting_comments_on_regulations_dot_gov,
    :significant,
    :correction,
  ]
  INTEGER_PARAMS_NEEDING_DESERIALIZATION = [
    'agency_ids',
    'cited_entry_ids',
    'section_ids',
    'topic_ids',
    'place_ids',
    'presidential_document_type_id',
    'small_entity_ids',
    'search_type_id',
  ]
  def deserialized_params
    params.tap do |modified_params|
      if modified_params[:conditions].present?
        BOOLEAN_PARAMS_NEEDING_DESERIALIZATION.each do |param_name|
          param = modified_params[:conditions].try(:[], param_name)
          if param.present?
            modified_params[:conditions][param_name] = Array.wrap(param).first.to_i
          end
        end

        INTEGER_PARAMS_NEEDING_DESERIALIZATION.each do |param_name|
          ids = modified_params[:conditions].try(:[], param_name)
          if ids.present?
            modified_params[:conditions][param_name] = Array.wrap(ids).map(&:to_i)
          end
        end
      end

      modified_params.delete(:callback)
    end
  end

  def entry_search(params, fields=[])
    term = params[:conditions].present? && params[:conditions][:term].present?
    excerpts = fields.include?(:excerpts)

    Entry.search_klass.new(
      params.permit!.to_h.deep_compact_blank.merge(excerpts: term && excerpts)
    )
  end

  def render_csv(entries, fields, filename)
    output = CSV.generate do |csv|
      csv << fields
      entries.each do |result|
        fields = (fields & EntrySerializer.api_fields)
        csv << fields.map do |field|
          value = [*result.send(field)].join('; ')

          if field == :document_number
            value = " #{value}"
          else
            value
          end
        end
      end
    end

    headers['Content-Disposition'] = "attachment; filename=\"#{filename}.csv\""

    render plain: output
  end

  def render_rss(documents, title)
    render :template => 'entries/index.rss.builder', :locals => {
      :documents => documents,
      :feed_name => title,
      :feed_description => "The documents in this feed originate from FederalRegister.gov which displays an unofficial web version of the daily Federal Register. The official electronic version in PDF format is also available as a link from the FederalRegister.gov website. For more information, please see https://www.federalregister.gov/reader-aids/policy/legal-status.",
      :feed_url => request.url
    }
  end

  def entry_data(entry, fields)
    allowed_fields = (fields & EntrySerializer.api_fields)
    Hash[ allowed_fields.map do |field|
      [field, entry.send(field)]
    end]
  end

  def index_url(options)
    api_v1_documents_url(options.permit!.except(:controller, :action))
  end

  def search_suggestions(search)
    suggestions = {}

    if search.explanatory_suggestion_attributes
      suggestions[:explanatory] = search.explanatory_suggestion_attributes
    end

    if search.suggestion && search.suggestion.count > 0
      suggestions[:search_refinement] = {
        :count => search.suggestion.count,
        :search_conditions => search.suggestion.conditions,
        :search_summary => view_context.search_suggestion_title(search.suggestion, search, :semantic => true)
      }
    end

    public_inspection_search = PublicInspectionDocument.search_klass.new_if_possible(
      :conditions => search.valid_conditions
    )
    if public_inspection_search && public_inspection_search.count > 0
      suggestions[:public_inspection] = {:count => public_inspection_search.count}
    end

    if search.filters.blank? && search.term.present?
      citation = search.matching_entry_citation
      if citation && citation.matching_fr_entries
        citation_attributes = {
          document_numbers: citation.matching_fr_entries.map(&:document_number),
        }
        if citation.citation_type == 'FR'
          citation_attributes[:volume] = citation.part_1
          citation_attributes[:page] = citation.part_2
        end

        suggestions[:citation] = citation_attributes
      end

      if view_context.is_cfr_citation?(search.term)
        title, part, section = Citations::CfrHelper::PATTERN.match(search.term).to_a.slice(1,3)
        suggestions[:cfr] = {
          :title => title,
          :part => part,
          :section => section
        }
      end

      if search.entry_with_document_number
        suggestions[:document_number] = {:document_number => search.entry_with_document_number.document_number}
      end
    end

    suggestions
  end

end
