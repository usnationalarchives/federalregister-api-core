class EventsController < ApplicationController
  include Icalendar
  def show
    @event = ::Event.find(params[:id])

    respond_to do |wants|
      wants.html do
        if request.xhr?
          render :layout => false
        else
          render
        end
      end
      wants.ics do
        cal = Calendar.new
        cal.add_event(@event.to_ics)
        cal.publish
        render :text => cal.to_ical
      end
    end
  end
end