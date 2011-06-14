class CitationsController < ApplicationController
  def show
    cache_for 1.day
    @volume = params[:volume].to_i
    @page   = params[:page].to_i
    
    @entries = Entry.find_all_by_citation(@volume, @page)
    
    case @entries.size
    when 1
      redirect_to entry_url(@entries.first), :status => :moved_permanently
    when 0
      render :action => 'show_none'
    else
      render :action => 'show_multiple'
    end
  end
  
  def search
    if params[:volume].present? && params[:page].present?
      redirect_to citation_url(params[:volume].to_i, params[:page].to_i)
    else
      render
    end
  end
end
