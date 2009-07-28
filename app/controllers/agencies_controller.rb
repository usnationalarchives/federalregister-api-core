class AgenciesController < ApplicationController
  
  def index
    @agencies  = Agency.find(:all, :order => 'name ASC')
    @chart_max = Agency.max_entry_count
    @featured_agencies = Agency.featured
    @week = params[:week].to_i || Time.now.strftime("%W").to_i
  end
  
  def show
    @agency = Agency.find_by_slug(params[:id], :include => :entries, :order => 'entries.publication_date DESC')
  end
end