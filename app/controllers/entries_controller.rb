class EntriesController < ApplicationController
  
  def index
    @year = params[:year]
    @month = params[:month]
    @entries = Entry.find(:all, :conditions => ['publication_date >= ?', "#{@year}-#{@month}-01"], :order => 'publication_date DESC')
  end
  
  def show
    @entry = Entry.find_by_id(params[:id])
  end
end