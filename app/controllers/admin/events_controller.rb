class Admin::EventsController < AdminController
  def index
    @search = Event.public_meeting.includes(:entry, :place).ransack(params[:q])
    @events = @search.result.paginate(:page => params[:page])
  end

  def new
    @event = Event.new(params[:event])
    @event.event_type = 'PublicMeeting'
    @event.title ||= @event.entry.try(:title)
    render :layout => !request.xhr?
  end

  def create
    @event = Event.new(event_params)
    @event.event_type = 'PublicMeeting'
    if params[:event][:place_id].present? && Event.find_by_id(params[:event][:place_id]).nil?
      @event.place = Place.new(
        params[:place].merge(:id => params[:event][:place_id])
      )
    end

    if @event.save
      if request.xhr?
        render :partial => "list_item", :locals => {:event => @event}, :layout => false
      else
        flash[:notice] = "Successfully created."
        redirect_to admin_events_url
      end
    else
      if request.xhr?
        render :action => :new, :layout => false, :status => :conflict
      else
        flash.now[:error] = "There was a problem."
        render :action => :new
      end
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])

    if @event.update_attributes(event_params)
      flash[:notice] = "Successfully updated."
      redirect_to admin_events_url
    else
      flash.now[:error] = "There was a problem."
      render :action => :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    if request.xhr?
        head :ok
    else
        flash[:notice] = "Successfully removed."
        redirect_to admin_events_url
    end
  end

  private

  def event_params
    params.require(:event).permit(
      :entry_id,
      :title,
      :date,
      :place_id,
      :remote_call_in_available,
      :place => [:name, :place_type, :longitude, :latitude]
    )
  end
end
