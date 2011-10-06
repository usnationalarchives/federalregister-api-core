class PublicInspectionController < ApplicationController
  def by_date
    cache_for 1.day

    @faux_controller = "entries"

    @date = parse_date_from_params
    @issue = PublicInspectionIssue.published.find_by_publication_date!(@date)
    @special_documents = TableOfContentsPresenter.new(@issue.public_inspection_documents.special_filing, :always_include_parent_agencies => true)
    @regular_documents = TableOfContentsPresenter.new(@issue.public_inspection_documents.regular_filing, :always_include_parent_agencies => true)
  end

  def by_month
    cache_for 1.day
    
    begin
      @date = Date.parse("#{params[:year]}-#{params[:month]}-01")
    rescue ArgumentError
      raise ActiveRecord::RecordNotFound
    end
    
    if params[:current_date]
      @current_date = Date.parse(params[:current_date])
    end
    
    @public_inspection_dates = PublicInspectionIssue.published.all(
      :conditions => {:publication_date => @date.beginning_of_day .. @date.end_of_month.end_of_day}
    ).map(&:publication_date)
    render :layout => false
  end
  
end
