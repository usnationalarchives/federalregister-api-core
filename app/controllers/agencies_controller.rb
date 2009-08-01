class AgenciesController < ApplicationController
  
  def index
    @agencies  = Agency.find(:all, :order => 'name ASC')
    @chart_max = Agency.max_entry_count
    @featured_agencies = Agency.featured
    @week = params[:week].to_i || Time.now.strftime("%W").to_i
  end
  
  def show
    @agency = Agency.find_by_slug(params[:id], :include => :entries, :order => 'entries.publication_date DESC')
    
    respond_to do |wants|
      wants.html
      
      wants.rss do
        @feed_name = "Trifecta: #{@agency.name}"
        @feed_description = "Recent Federal Register entries from #{@agency.name}."
        @entries = @agency.entries.all(:include => [:topics, :agency], :order => "publication_date DESC", :limit => 20)
        render :template => 'entries/index.rss.builder'
      end
    end
    
  end
end