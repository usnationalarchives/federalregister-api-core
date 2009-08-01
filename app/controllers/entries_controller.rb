class EntriesController < ApplicationController
  def search
    @search_term = params[:q]
    @entries = Entry.search(@search_term, :page => params[:page], :sort => 'agency')
  end
  
  def index
    @entries = Entry.find(:all, :limit => 200, :order => "publication_date DESC")
  end
  
  def by_date
    @year = params[:year]   || Time.now.strftime("%Y")
    @month = params[:month] || Time.now.strftime("%m")
    @day   = params[:day]   || Time.now.strftime("%d")
    
    @entries = Entry.find(:all, :conditions => ['publication_date = ?', "#{@year}-#{@month}-#{@day}"], :order => 'publication_date DESC')
  end
  
  def show
    @entry = Entry.find_by_document_number(params[:document_number])
    raise "Entry doesn't exist" if @entry.nil?
  end
end