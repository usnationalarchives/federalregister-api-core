class CitationsController < ApplicationController
  def index
    volume = params[:volume]
    page   = params[:page]
    
    fr_citation = "#{volume} FR #{page}"
    @entries = Entry.find(:all, :conditions => ['citation = ?', fr_citation] )
    
    if @entries.size == 1
      redirect_to entry_url(@entries.first)
    else
      render
    end
  end
end
