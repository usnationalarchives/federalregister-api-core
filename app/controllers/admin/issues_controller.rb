class Admin::IssuesController < AdminController
  def show
    @publication_date = Date.parse(params[:id])
    @entries_without_sections = Entry.published_on(@publication_date).all(:include => :sections, :conditions => "sections.id IS NULL")
    @sections = Section.all
  end
end