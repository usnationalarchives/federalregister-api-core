class AgenciesController < ApplicationController
  def index
    @agencies  = Agency.all(:order => 'name ASC', :include => :children)
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
          :conditions => {:agency_assignments => {:assignable_id => @agency.id, :assignable_type => "Entry"}},
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