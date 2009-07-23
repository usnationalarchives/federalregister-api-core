class AgenciesController < ApplicationController
  
  def index
    @agencies = Agency.find(:all, :order => 'name ASC')
  end
  
  def show
    @agency = Agency.find_by_id(params[:id], :include => :entries, :order => 'entries.publication_date DESC')
  end
end