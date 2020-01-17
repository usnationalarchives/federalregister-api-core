class Admin::CannedSearchesController < AdminController
  def section
    @section = Section.find_by_slug!(params[:slug])
    @active_canned_searches = @section.canned_searches.active.in_order
    @inactive_canned_searches = @section.canned_searches.inactive.in_order
  end

  def index
    @sections = Section.all
  end

  def new
    @canned_search = CannedSearch.new(active: 1)
  end

  def create
    @canned_search = CannedSearch.new(canned_search_params)
    if @canned_search.save
      flash[:notice] = "Record saved."
      redirect_to admin_section_canned_searches_path(@canned_search.section.slug)
    else
      render :action => :new
    end
  end

  def edit
    @canned_search = CannedSearch.find(params[:id])
  end

  def update
    @canned_search = CannedSearch.find(params[:id])
    if @canned_search.update_attributes(canned_search_params)
      if request.xhr?
        head :ok
      else
        flash[:notice] = 'Record saved.'
        redirect_to admin_section_canned_searches_path(@canned_search.section.slug)
      end
    else
      render :action => :edit
    end
  end

  def delete
    @canned_search = CannedSearch.find(params[:id])
  end

  def destroy
    @canned_search = CannedSearch.find(params[:id])
    @canned_search.destroy
    flash[:notice] = "Record deleted."
    redirect_to admin_section_canned_searches_path(@canned_search.section.slug)
  end

  private

  def canned_search_params
    params.require(:canned_search).permit(
      :title,
      :section_id,
      :description,
      :search_url,
      :active
    )
  end
end
