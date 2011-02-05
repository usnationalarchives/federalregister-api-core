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
      
      wants.csv do
        columns = %w(id name short_name url description)
        rows = [columns.to_csv] + Agency.all(:order => "agencies.name").map{|agency| columns.map{|column| agency.send(column)}.to_csv}
        render :text => rows
      end
    end
  end
  
  def new
    @agency = Agency.new
  end
  
  def create
    @agency = Agency.new(params[:agency])
    
    if @agency.save
      flash[:notice] = "Successfully created."
      redirect_to admin_agencies_url
    else
      flash.now[:error] = "There was a problem."
      render :action => :new
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
  
  def delete
    @agency = Agency.find_by_slug!(params[:id])
  end
  
  def destroy
    @agency = Agency.find_by_slug!(params[:id])
    unless @agency.entries.present?
      flash[:notice] = "Agency #{@agency.name} has been removed."
      @agency.destroy
    end
    redirect_to admin_agencies_url
  end
end