class Admin::TopicsController < AdminController
  def index
    respond_to do |wants|
      wants.json do
        @topics = Topic.order("topics.name")
        render :json => @topics.to_json(:only => [ :id, :name ])
      end
    end
  end
end
