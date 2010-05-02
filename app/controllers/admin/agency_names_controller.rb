class Admin::AgencyNamesController < AdminController
  def index
    @agency_names = AgencyName.all(
      :select => "agency_names.*, COUNT(agency_name_assignments.id) AS entries_count",
      :joins => :agency_name_assignments,
      :order => "agency_names.name",
      :group => "agency_names.id"
    )
  end
  
  def unprocessed
    @unprocessed_agency_names = AgencyName.unprocessed
  end
  
  def edit
    @agency_name = AgencyName.find(params[:id])
  end
  
  def update
    @agency_name = AgencyName.find(params[:id])
    
    agency_id = params[:agency_name][:agency_id]
    
    if agency_id.present?
      @agency_name.agency_assigned = true
      @agency_name.agency_id = agency_id
    else
      @agency_name.agency_assigned = false
    end
    
    @agency_name.save!
    flash[:notice] = 'Successfully saved'
    
    next_agency_name = AgencyName.unprocessed.first
    if next_agency_name
      redirect_to edit_admin_agency_name_path(next_agency_name)
    else
      redirect_to unprocessed_admin_agency_names_path
    end
  end
end