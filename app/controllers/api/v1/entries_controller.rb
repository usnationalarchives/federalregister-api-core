class Api::V1::EntriesController < ApiController
  def index
    respond_to do |wants|
      cache_for 1.day
      search = EntrySearch.new(params)

      wants.json do
        fields = specified_fields || EntryApiRepresentation.default_index_fields_json
        find_options = EntryApiRepresentation.find_options_for(fields)

        render_search(search, find_options, params[:metadata_only]) do |result| 
          entry_data(result, fields)
        end
      end

      wants.csv do
        fields = specified_fields || EntryApiRepresentation.default_index_fields_csv
        find_options = EntryApiRepresentation.find_options_for(fields)

        filename = search.summary.gsub(/\W+/, '_').sub(/_$/,'').downcase
        entries = search.results(find_options)
        render_csv(entries, fields, filename)
      end
    end
  end

  def facets
    field_facets = %w(agency topic section type)
    date_facets = %w(daily weekly monthly quarterly yearly)
    raise ActiveRecord::RecordNotFound unless (field_facets + date_facets).include?(params[:facet])

    search = EntrySearch.new(params)
    if search.valid?
      if date_facets.include?(params[:facet])
        json = search.date_distribution(:period => params[:facet].to_sym).results
      else
        facets = search.send("#{params[:facet]}_facets")

        json = facets.each_with_object(Hash.new) do |facet, hsh|
          hsh[facet.identifier] = {
            :count => facet.count,
            :name => facet.name
          }
        end
      end
      render_json_or_jsonp(json)
    else
      render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
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

        render_one_or_more(Entry, params[:id]) do |entry|
          entry_data(entry, fields)
        end
      end
      wants.csv do
        fields = specified_fields || CSV_FIELDS 
        document_numbers = params[:id].split(',')
        entries = Entry.all(:conditions => {:document_number => document_numbers})
        filename = 'federal_register'
        render_csv(entries, fields, filename)
      end
    end
  end
 
  private

  def render_csv(entries, fields, filename)
    output = FasterCSV.generate do |csv|
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
        suggestions[:citation] = {:document_numbers => citation.matching_fr_entries.map(&:document_number)}
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
