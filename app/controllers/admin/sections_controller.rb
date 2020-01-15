class Admin::SectionsController < AdminController
  def index
    @sections = Section.all
  end

  def show
    @section = Section.find_by_slug(params[:id])
  end

  def new
    @section = Section.new(params[:section])
  end

  def create
    @section = Section.new(section_params)
    if @section.save
      flash[:notice] = "Successfully created."
      redirect_to admin_section_url(@section)
    else
      flash.now[:error] = "There was a problem."
      render :action => :new
    end
  end

  def edit
    @section = Section.find_by_slug(params[:id])
  end

  def update
    @section = Section.find_by_slug(params[:id])

    if @section.update_attributes(section_params)
      flash[:notice] = "Successfully updated."
      redirect_to admin_section_url(@section)
    else
      flash.now[:error] = "There was a problem."
      render :action => :edit
    end
  end

  private

  def section_params
    params.require(:section).permit(:title, :slug, :agency_ids, :description, :relevant_cfr_sections)
  end
end
