class Admin::AgenciesController < AdminController
  def index
    respond_to do |wants|
      wants.html do
        @search = Agency.scoped(:order => "agencies.name").search(params[:search])
        @agencies = @search.all.paginate(:per_page => 20, :page => params[:page])
      end
      
      wants.json do
        agencies = Agency.all(:order => "agencies.name")
        render :json => agencies.to_json(:only => [ :id, :name ])
      end
    end
  end
  
  def edit
    @agency = Agency.find_by_slug!(params[:id])
  end
  
  def update
    @agency = Agency.find_by_slug!(params[:id])
    
    if @agency.update_attributes(params[:agency])
      flash[:notice] = "Successfully saved."
      redirect_to admin_agencies_url
    else
      flash.now[:error] = "There was a problem."
      render :action => :edit
    end
  end
end