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
    
    @entry_text = render_to_string( :partial => "entries/abstract", :locals => {:entry => @entry} ) +
      render_to_string( :partial => "entries/full_text", :locals => {:entry => @entry} )
    @dates = PotentialDateExtractor.extract(@entry_text)

    placemaker = Placemaker.new(:application_id => ENV['yahoo_placemaker_api_key'])
    if @entry.full_xml
      @places = []#placemaker.places(@entry.full_xml[0,45000])
    else
      @places = []
    end
  end
end