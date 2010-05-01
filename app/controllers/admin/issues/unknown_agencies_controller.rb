class Admin::Issues::UnknownAgenciesController < AdminController
  def index
    @publication_date = Date.parse(params[:issue_id])
    @unknown_agency_names = Entry.published_on(@publication_date).with_agency_name.without_agency_assigned.group_by(&:primary_agency_raw)
  end
  
  def edit
    @publication_date = Date.parse(params[:issue_id])
    @unknown_agency_name = params[:id]
    @entries = Entry.published_on(@publication_date).with_agency_name.without_agency_assigned.scoped(:conditions => {:primary_agency_raw => @unknown_agency_name})
    @alternative_agency_name = AlternativeAgencyName.new(:name => @unknown_agency_name)
  end
  
  def update
    @publication_date = Date.parse(params[:issue_id])
    @unknown_agency_name = params[:id]
    @entries = Entry.published_on(@publication_date).with_agency_name.without_agency_assigned.scoped(:conditions => {:primary_agency_raw => @unknown_agency_name})
    
    @alternative_agency_name = AlternativeAgencyName.new(params[:alternative_agency_name])
    @alternative_agency_name.name = @unknown_agency_name
    
    if @alternative_agency_name.save
      @entries.each do |entry|
        Content::EntryImporter.new(:entry => entry).update_attributes(:agency_id, :section_ids)
      end
      
      redirect_to admin_issue_unknown_agencies_url(@publication_date.to_s(:db))
    else
      render :action => :edit
    end
  end
end