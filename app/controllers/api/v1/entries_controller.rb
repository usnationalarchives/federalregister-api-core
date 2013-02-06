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
            value = "#{value} "
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

end
