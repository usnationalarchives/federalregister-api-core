class Api::V1::EntriesController < ApiController
  def index
    respond_to do |wants|
      cache_for 1.day

      wants.json do
        fields = specified_fields || EntryApiRepresentation.default_index_fields_json
        find_options = EntryApiRepresentation.find_options_for(fields)

        search = entry_search(params, fields)

        render_search(search, find_options, params[:metadata_only]) do |result|
          entry_data(result, fields)
        end
      end

      wants.csv do
        fields = specified_fields || EntryApiRepresentation.default_index_fields_csv
        find_options = EntryApiRepresentation.find_options_for(fields)

        search = entry_search(params, fields)
        filename = search.summary.gsub(/\W+/, '_').sub(/_$/,'').downcase
        entries = search.results(find_options)
        render_csv(entries, fields, filename)
      end

      wants.rss do
        fields = EntryApiRepresentation.default_index_fields_rss
        find_options = EntryApiRepresentation.find_options_for(fields)

        search = entry_search(
          params.merge(order: 'newest', per_page: 200),
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
      search = EntrySearch.new(params)

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

  def search_details
    search = EntrySearch.new(params)
    if search.valid?
      render_json_or_jsonp(
        :suggestions => search_suggestions(search),
        :filters => search_filters(search)
      )
    else
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
    end
  end

  def show
    respond_to do |wants|
      wants.json do
        cache_for 1.day

        fields = specified_fields || EntryApiRepresentation.default_show_fields_json
        if params[:id] =~ /FR/
          fields = fields + [:citation]
        end
        find_options = EntryApiRepresentation.find_options_for(fields + [:document_number])

        render_one_or_more(Entry, params[:id], find_options) do |entry|
          entry_data(entry, fields)
        end
      end
      wants.csv do
        fields = specified_fields || EntryApiRepresentation.default_show_fields_csv
        document_numbers = params[:id].split(',')
        entries = Entry.all(:conditions => {:document_number => document_numbers})
        filename = 'federal_register'
        render_csv(entries, fields, filename)
      end
    end
  end

  private

  def entry_search(params, fields=[])
    term = params[:conditions].present? && params[:conditions][:term].present?
    excerpts = fields.include?(:excerpts)

    EntrySearch.new(params.merge(excerpts: term && excerpts))
  end

  def render_csv(entries, fields, filename)
    output = CSV.generate do |csv|
      csv << fields
      entries.each do |result|
        representation = EntryApiRepresentation.new(result)
        csv << fields.map do |field|
          value = [*representation.value(field)].join('; ')

          if field == :document_number
            value = " #{value}"
          else
            value
          end
        end
      end
    end

    headers['Content-Disposition'] = "attachment; filename=\"#{filename}.csv\""

    render :text => output
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
    representation = EntryApiRepresentation.new(entry)
    Hash[ fields.map do |field|
      [field, representation.value(field)]
    end]
  end

  def index_url(options)
    api_v1_entries_url(options)
  end

  def search_suggestions(search)
    suggestions = {}

    if search.suggestion
      suggestions[:search_refinement] = {
        :count => search.suggestion.count,
        :search_conditions => search.suggestion.conditions,
        :search_summary => view_context.search_suggestion_title(search.suggestion, search, :semantic => true)
      }
    end

    public_inspection_search = PublicInspectionDocumentSearch.new_if_possible(
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

  def search_filters(search)
    search.filters.map.each_with_object(Hash.new){|filter,hsh|
      hsh[filter.condition] = {
        :name => filter.name,
        :value => filter.label
      }
    }
  end
end
