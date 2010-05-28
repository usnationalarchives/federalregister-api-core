class Admin::AgencyNamesController < AdminController
  def index
    search_options = params[:search] || {}
    search_options['order'] ||= 'ascend_by_name'
    @search = AgencyName.searchlogic(search_options)
    
    @agency_names = @search.paginate(:page => params[:page])
  end
  
  def unprocessed
    @unprocessed_agency_names = AgencyName.unprocessed
  end
  
  def edit
    @agency_name = AgencyName.find(params[:id])
  end
  
  def update
    @agency_name = AgencyName.find(params[:id])
    
    if @agency_name.update_attributes(params[:agency_name])
      flash[:notice] = 'Successfully saved'
      next_agency_name = AgencyName.unprocessed.first(:conditions => ["agency_names.name > ?", @agency_name.name])
      if next_agency_name
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