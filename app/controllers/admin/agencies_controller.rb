class Admin::AgenciesController < AdminController
  layout 'admin_bootstrap'
  include CloudfrontUtils

  def index
    respond_to do |wants|
      wants.html do
        @search = Agency.scoped(:order => "agencies.name").ransack(params[:q])
        @agencies = @search.result.paginate(:per_page => 20, :page => params[:page])
      end

      wants.json do
        agencies = Agency.order("agencies.name")
        render :json => agencies.to_json(:only => [ :id, :name ])
      end

      wants.csv do
        columns = %w(id name short_name url description)
        csv = CSV.generate do |csv|
          csv << columns
          Agency.
            order("agencies.name").
            map{|agency| columns.map{|column| agency.send(column) }}.
            each{|row| csv << row }
        end
        send_data csv
      end
    end
  end

  def new
    @agency = Agency.new
  end

  def create
    @agency = Agency.new(agency_params)

    if @agency.save
      flash[:notice] = "Successfully created.  Please be sure to assign documents via the Agencies > Agency Names menu option"
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
    original_slug = @agency.slug

    if @agency.update(agency_params)
      if original_slug != @agency.slug
        Honeybadger.notify(
          :error_class   => "Agency name changed",
          :parameters => {
            :original_slug => original_slug,
            :new_slug      => @agency.slug,
           }
        )
      end
      send_cloudfront_invalidation!
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

  private

  def agency_params
    params.require(:agency).permit(:name, :short_name, :slug, :pseudonym, :parent_id, :description, :url, :logo)
  end

  def send_cloudfront_invalidation!
    if @agency.logo.present?
      create_invalidation(
        Settings.s3_host_aliases.agency_logos,
        @agency.s3_attachment_paths
      )
    end
  end
end
