class CitationsController < ApplicationController
  def show
    @volume = params[:volume].to_i
    @page   = params[:page].to_i
    
    @entries = Entry.all(:conditions => "volume = #{@volume} AND start_page <= #{@page} AND end_page >= #{@page}", :order => "entries.end_page")
    
    case @entries.size
    when 1
      redirect_to entry_url(@entries.first)
    when 0
      render :action => 'show_none'
    else
      render :action => 'show_multiple'
    end
  end
end
