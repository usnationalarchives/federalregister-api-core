class Admin::Issues::EventfulEntriesController < AdminController
  def index
    @publication_date = Date.parse(params[:issue_id])
    
    @entries = EntrySearch.new(
      :q => '"public meeting"',
      :publication_date_greater_than => @publication_date.to_s,
      :publication_date_less_than => @publication_date.to_s,
      :per_page => 50
    ).entries
  end
  
  def show
    @publication_date = Date.parse(params[:issue_id])
    @entry = Entry.published_on(@publication_date).find_by_document_number!(params[:id])
    
    @dates = PotentialDateExtractor.extract(@entry.full_xml)

    placemaker = Placemaker.new(:application_id => ENV['yahoo_placemaker_api_key'])
    if @entry.full_text
      @places = placemaker.places(@entry.full_text)
    else
      @places = []
    end
  end
end