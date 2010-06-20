class Admin::Issues::EventfulEntriesController < AdminController
  def index
    @publication_date = Date.parse(params[:issue_id])
    
    @entries = EntrySearch.new(
      :conditions => {:term => '"public meeting"', :start_date => @publication_date.to_s, :end_date => @publication_date.to_s},
      :per_page => 200,
      :match_mode => :extended
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
      @places = placemaker.places(@entry.full_xml)
    else
      @places = []
    end
  end
end