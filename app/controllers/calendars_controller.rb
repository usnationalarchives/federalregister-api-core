class CalendarsController < ApplicationController
  
  def index
    @year  = params[:year].to_i  || Time.now.strftime("%Y")
    @month = params[:month].to_i
    @day   = params[:day]
    
    if @day.nil?
      date_range = [Date.new(@year, @month, 1), Date.new(@year, @month, -1)]
      @referenced_dates = ReferencedDate.find(:all, :include => :entry, :conditions => {:date => date_range[0]..date_range[1]}, :order => 'date ASC' )
    else                                                  
      @referenced_dates = ReferencedDate.find(:all, :include => :entry, :conditions => ['date = ?', Date.new(@year, @month, @day.to_i)], :order => 'date ASC' )
    end
  end
  
end
