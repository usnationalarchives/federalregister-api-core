class AgenciesController < ApplicationController
    
  caches_page :index, :show
  def index
    @agencies  = Agency.all(:order => 'name ASC')
    @weekly_chart_max = @agencies.map{|a| a.entries_1_year_weekly.map(&:to_i).max}.max
    @featured_agencies = Agency.featured.find(:all, :select => "agencies.*,
        (SELECT count(*) FROM entries JOIN agency_assignments ON agency_assignments.entry_id = entries.id WHERE agency_assignments.agency_id = agencies.id AND publication_date > '#{30.days.ago.to_s(:db)}') AS num_entries_month,
        (SELECT count(*) FROM entries JOIN agency_assignments ON agency_assignments.entry_id = entries.id WHERE agency_assignments.agency_id = agencies.id AND publication_date > '#{90.days.ago.to_s(:db)}') AS num_entries_quarter,
        (SELECT count(*) FROM entries JOIN agency_assignments ON agency_assignments.entry_id = entries.id WHERE agency_assignments.agency_id = agencies.id AND publication_date > '#{365.days.ago.to_s(:db)}') AS num_entries_year"
    )
    @week = params[:week].to_i || Time.now.strftime("%W").to_i
  end
  
  def show
    @agency = Agency.find_by_slug!(params[:id])
    @entries = @agency.entries.all(:limit => 50, :include => :places, :order => "entries.publication_date DESC", :group => "entries.id")
    respond_to do |wants|
      wants.html do
        @most_cited_entries = @agency.entries.all(:conditions => "citing_entries_count > 0", :order => "citing_entries_count DESC, publication_date DESC", :limit => 50, :group => "entries.id")
        @significant_entries = @agency.entries.significant.all(:conditions => {:publication_date => (3.month.ago .. Date.today)}, :group => "entries.id")
        
        # Entry types
        @entry_type_labels = []
        @entry_type_values = []
        
        by_entry_type = Entry.all(
          :select => 'granule_class, count(*) AS count',
          :conditions => {:agency_assignments => {:agency_id => @agency.id}},
          :joins => :agency_assignments,
          :group => 'granule_class',
          :order => 'count DESC'
        )
        by_entry_type.each do |summary|
          @entry_type_labels << summary.entry_type
          @entry_type_values << summary.count.to_i
        end
      end
      
      wants.rss do
        @feed_name = "Federal Register: #{@agency.name}"
        @feed_description = "Recent Federal Register entries from #{@agency.name}."
        @entries = @agency.entries.all(:include => [:topics, :agency], :order => "publication_date DESC", :limit => 20)
        render :template => 'entries/index.rss.builder'
      end
    end
    
  end
end