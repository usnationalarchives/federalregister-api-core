class PublicInspectionController < ApplicationController
  def by_date
    cache_for 1.day

    @date = parse_date_from_params
    @special_documents = TableOfContentsPresenter.new(PublicInspectionDocument.special_filing.available_on(@date))
    @regular_documents = TableOfContentsPresenter.new(PublicInspectionDocument.regular_filing.available_on(@date))
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
    
    @public_inspection_dates = PublicInspectionDocument.regular_filing.all(
      :select => "DISTINCT(DATE(filed_at)) AS filed_on",
      :conditions => {:filed_at => @date.beginning_of_day .. @date.end_of_month.end_of_day}
    ).map{|pi| Date.parse(pi.filed_on)}
    render :layout => false
  end
  
end
