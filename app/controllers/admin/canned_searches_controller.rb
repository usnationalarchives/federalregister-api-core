class Admin::CannedSearchesController < AdminController
  def section
    @section = Section.find_by_slug!(params[:slug])
    @canned_searches = @section.canned_searches
  end

  def index
    @sections = Section.all
  end

  def new
    @canned_search = CannedSearch.new({:active => 1}.merge(params[:canned_search]||{}))
  end

  def create
    @canned_search = CannedSearch.new(params[:canned_search])
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
    if @canned_search.update_attributes(params[:canned_search])
      if request.xhr?
        render :nothing => true
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
end
