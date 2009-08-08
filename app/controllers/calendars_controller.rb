class CalendarsController < ApplicationController
  caches_page :index
  
  def index
    @year  = params[:year].to_i  || Time.now.strftime("%Y")
    @month = params[:month].to_i
    @day   = params[:day]
    
    if @day.nil?
      date_range = [Date.new(@year, @month, 1), Date.new(@year, @month, -1)]
      @referenced_dates = ReferencedDate.find(:all, :include => {:entry => :agency}, :conditions => {:date => date_range[0]..date_range[1]}, :order => 'date ASC' )
    else                                                  
      @referenced_dates = ReferencedDate.find(:all, :include => {:entry => :agency}, :conditions => ['date = ?', Date.new(@year, @month, @day.to_i)], :order => 'date ASC' )
    end
    
    @entries = @referenced_dates.map{|rf| rf.entry}.uniq
    
    agencies_and_entry_counts = []
    @entries.group_by(&:agency_id).each do |agency_id, entries|
      next if agency_id.blank?
      agencies_and_entry_counts << [Agency.find(agency_id), entries.size]
    end
    
    @agency_labels = []
    @agency_values = []
    agencies_and_entry_counts.sort_by{|a| a[1]}.reverse[0,10].each do |agency, count|
      @agency_labels << "#{agency.sidebar_name}"
      @agency_values << count
    end
    
    if @agency_values.sum < @entries.size
      count = (@entries.size - @agency_values.sum)
      @agency_labels << "Other"
      @agency_values << count
    end
    
    @granule_labels = []
    @granule_values = []
    @entries.group_by(&:granule_class).each do |granule_class, entries|
      @granule_labels << granule_class
      @granule_values << entries.size
    end
    
  end
  
end
