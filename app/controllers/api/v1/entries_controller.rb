class Api::V1::EntriesController < ApiController
  def index
    respond_to do |wants|
      wants.json do
        search = EntrySearch.new(params)
        data = { :count => search.count }
        
        if search.count > 0 && search.results.count > 0
          data[:total_pages] = search.results.total_pages
          
          if search.results.next_page
            data[:next_page_url] = url_for(params.merge(:page => search.results.next_page))
          end
          
          if search.results.previous_page
            data[:previous_page_url] = url_for(params.merge(:page => search.results.previous_page))
          end
          
          data[:results] = search.results.map do |entry|
            {
              :title            => entry.title,
              :type             => entry.entry_type,
              :abstract         => entry.abstract,
              :excerpts         => entry.excerpts.full_text || entry.excerpts.abstract,
              :document_number  => entry.document_number,
              :url              => entry_url(entry),
              :pdf_url          => entry.source_url('pdf'),
              :publication_date => entry.publication_date,
              :agencies         => entry.agency_names.map(&agency_proc)
            }
          end
        end
        
        render :json => data
      end
    end
  end
  
  private
  
  def agency_proc
    Proc.new do |agency_name|
      agency = agency_name.agency
      if agency
        {
          :raw_name => agency_name.name,
          :name     => agency.name,
          :id       => agency.id,
          :url      => agency_url(agency)
        }
      else
        {
          :raw_name => agency_name.name
        }
      end
    end
  end
end