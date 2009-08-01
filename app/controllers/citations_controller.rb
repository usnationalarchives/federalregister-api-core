class CitationsController < ApplicationController
  def index
    volume = params[:volume]
    page   = params[:page]
    
    fr_citation = "#{volume} FR #{page}"
    @entries = Entry.find(:all, :conditions => ['citation = ?', fr_citation] )
  end
end
