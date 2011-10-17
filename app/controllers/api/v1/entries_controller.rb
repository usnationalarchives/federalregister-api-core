class Api::V1::EntriesController < ApiController
  def index
    respond_to do |wants|
      wants.json do
        search = EntrySearch.new(params)
        if ! search.valid?
          cache_for 1.day
          render_json_or_jsonp({:errors => search.validation_errors}, :status => 400)
          return
        end

        data = { :count => search.count }
        
        if search.count > 0 && search.results.count > 0
          data[:total_pages] = search.results.total_pages
          
          if search.results.next_page
            data[:next_page_url] = api_v1_entries_url(params.merge(:page => search.results.next_page))
          end
          
          if search.results.previous_page
            data[:previous_page_url] = api_v1_entries_url(params.merge(:page => search.results.previous_page))
          end
          
          data[:results] = search.results.map do |entry|
            basic_entry_data(entry).merge(
              :excerpts => entry.excerpts.full_text || entry.excerpts.abstract,
              :json_url => api_v1_entry_url(entry.document_number, :format => :json)
            )
          end
        end
        
        cache_for 1.day
        render_json_or_jsonp data
      end
    end
  end
  
  def show
    respond_to do |wants|
      wants.json do
        if params[:id] =~ /,/
          document_numbers = params[:id].split(',')
          entries = Entry.all(:conditions => {:document_number => document_numbers})
          
          data = {
            :count => entries.count,
            :results => entries.map{|e| full_entry_data(e)}
          }

          missing = document_numbers - entries.map(&:document_number)
          if missing.present?
            data[:errors] = {:not_found => missing}
          end
        else
          entry = Entry.find_by_document_number!(params[:id])
          data = full_entry_data(entry)
        end
        cache_for 1.day
        render_json_or_jsonp data
      end
    end
  end
 
  private
  
  def basic_entry_data(entry)
    {
      :title            => entry.title,
      :type             => entry.entry_type,
      :abstract         => entry.abstract,
      :document_number  => entry.document_number,
      :html_url         => entry_url(entry),
      :pdf_url          => entry.source_url('pdf'),
      :publication_date => entry.publication_date,
      :agencies         => entry.agency_names.map{|agency_name|
        agency = agency_name.agency
        if agency
          {
            :raw_name => agency_name.name,
            :name     => agency.name,
            :id       => agency.id,
            :url      => agency_url(agency),
            :json_url => api_v1_agency_url(agency.id, :format => :json)
          }
        else
          {
            :raw_name => agency_name.name
          }
        end
      }
    }
  end

  def full_entry_data(entry)
    basic_entry_data(entry).merge({
        :full_text_xml_url => entry_xml_url(entry),
        :abstract_html_url => entry_abstract_url(entry),
        :body_html_url => entry_full_text_url(entry),
        :mods_url => entry.source_url(:mods),
        :action => entry.action,
        :dates  => entry.dates,
        :effective_on  => entry.effective_on,
        :comments_close_on  => entry.comments_close_on,
        :start_page => entry.start_page,
        :end_page => entry.end_page,
        :volume => entry.volume,
        :docket_id => entry.docket_numbers.first.try(:number), # TODO: include all
        :regulation_id_numbers => entry.entry_regulation_id_numbers.map(&:regulation_id_number),
        :cfr_references => entry.entry_cfr_references.map{|cfr_reference|
          {:title => cfr_reference.title, :part => cfr_reference.part}
        }
      }
    )
  end
end
