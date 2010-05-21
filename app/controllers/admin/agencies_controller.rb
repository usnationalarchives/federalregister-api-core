class Admin::AgenciesController < AdminController
  def index
    respond_to do |wants|
      wants.json do
        @agencies = Agency.all(:order => "agencies.name")
        render :json => @agencies.to_json(:only => [ :id, :name ])
      end
    end
  end
end