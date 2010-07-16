class Admin::Issues::EventfulEntriesController < AdminController
  EVENT_PHRASES = ["public meeting", "public hearing", "town hall meeting", "web dialogue", "webinar"]
  
  def index
    @publication_date = Date.parse(params[:issue_id])
    
    @entries = EntrySearch.new(
      :conditions => {
        :term => "(#{EVENT_PHRASES.map{|phrase| "\"#{phrase}\""}.join('|')})",
        :date => @publication_date.to_s
      },
      :per_page => 200
    ).results
  end
  
  def show
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    
    @entry_text = get_abstract(@entry) + get_full_text(@entry)
    
    @dates = PotentialDateExtractor.extract(@entry_text)
    
    placemaker = Placemaker.new(:application_id => ENV['yahoo_placemaker_api_key'])
    begin
      @places = placemaker.places(@entry.full_xml[0,45000]) || []
    rescue Curl::Err::HostResolutionError => e
      if RAILS_ENV == 'development'
        @places = []
      else
        raise e
      end
    end
  end
  
  private
  
  def get_abstract(entry)
    if RAILS_ENV == 'development'
      render_to_string( :partial => "entries/abstract", :locals => {:entry => @entry} )
    else
      c = Curl::Easy.new('http://static.fr2.ec2.internal:8080' + entry_abstract_path(entry))
      c.http_get
      c.body_str
    end
  end
  
  def get_full_text(entry)
    if RAILS_ENV == 'development'
      render_to_string( :partial => "entries/full_text", :locals => {:entry => @entry} )
    else
      c = Curl::Easy.new('http://static.fr2.ec2.internal:8080' + entry_full_text_path(entry))
      c.http_get
      c.body_str
    end
  end
end