class Admin::AgencyNamesController < AdminController
  def index
    respond_to do |wants|
      wants.html do
        search_options = params[:search] || {}
        search_options['order'] ||= 'ascend_by_name'
        @search = AgencyName.searchlogic(search_options)
        @agency_names = @search.paginate(:page => params[:page])
      end
      
      wants.csv do
        agency_names = AgencyName.all(:order => "agency_names.name", :include => :agency)
        rows = [["agency_name", "agency"].to_csv] + 
          agency_names.map{|agency_name| [agency_name.name, agency_name.void? ? 'Void' : agency_name.agency.try(:name)].to_csv}
        render :text => rows
      end
      
    end
  end
  
  def unprocessed
    @unprocessed_agency_names = AgencyName.unprocessed.paginate(:page => params[:page])
  end
  
  def edit
    @agency_name = AgencyName.find(params[:id])
  end
  
  def update
    @agency_name = AgencyName.find(params[:id])
    
    if @agency_name.update_attributes(params[:agency_name])
      flash[:notice] = 'Successfully saved'
      if params[:return_to]
        redirect_to params[:return_to]
      elsif next_agency_name = AgencyName.unprocessed.first(:conditions => ["agency_names.name > ?", @agency_name.name])
        redirect_to edit_admin_agency_name_path(next_agency_name)
      else
        redirect_to unprocessed_admin_agency_names_path
      end
    else
      flash.now[:error] = 'There was a problem.'
      render :action => :edit
    end
  end
end
