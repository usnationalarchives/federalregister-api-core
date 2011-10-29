class Api::V1::EntriesController < ApiController
  def index
    respond_to do |wants|
      wants.json do
        cache_for 1.day
        search = EntrySearch.new(params)
        render_search(search) do |result| 
          basic_entry_data(result).merge(
            :excerpts => result.excerpts.raw_text_via_db || result.excerpts.abstract,
            :json_url => api_v1_entry_url(result.document_number, :format => :json)
          )
        end
      end
    end
  end
  
  def show
    respond_to do |wants|
      wants.json do
        cache_for 1.day
        render_one_or_more(Entry, params[:id]) do |entry|
          full_entry_data(entry)
        end
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
      :public_inspection_pdf_url => entry.public_inspection_document.try(:pdf).try(:url),
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
        :docket_id => entry.docket_numbers.first.try(:number), # backwards compatible for now
        :docket_ids => entry.docket_numbers.map(&:number),
        :regulation_id_numbers => entry.entry_regulation_id_numbers.map(&:regulation_id_number),
        :cfr_references => entry.entry_cfr_references.map{|cfr_reference|
          {:title => cfr_reference.title, :part => cfr_reference.part}
        }
      }
    )
  end
end
