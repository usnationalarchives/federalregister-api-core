class EntriesController < ApplicationController
  
  def index
    @year = params[:year]   || Time.now.strftime("%Y")
    @month = params[:month] || Time.now.strftime("%m")
    @day   = params[:day]   || Time.now.strftime("%d")
    
    @entries = Entry.find(:all, :conditions => ['publication_date >= ?', "#{@year}-#{@month}-#{@days}"], :order => 'publication_date DESC')
  end
  
  def show
    @entry = Entry.find_by_document_number(params[:document_number])
    raise "Entry doesn't exist" if @entry.nil?
  end
end