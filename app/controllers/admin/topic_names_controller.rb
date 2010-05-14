class Admin::TopicNamesController < AdminController
  def index
    search_options = params[:search] || {}
    search_options['order'] ||= 'ascend_by_name'
    @search = TopicName.scoped(
      :include => [:topics]
    ).searchlogic(search_options)
    
    @topic_names = @search.paginate(:page => params[:page])
  end
  
  def unprocessed
    @unprocessed_topic_names = TopicName.unprocessed
  end
  
  def edit
    @topic_name = TopicName.find(params[:id])
  end
  
  def update
    @topic_name = TopicName.find(params[:id])
    
    # agency_id = params[:topic_name][:agency_id]
    # 
    # if agency_id.present?
    #   @topic_name.agency_assigned = true
    #   @topic_name.agency_id = agency_id
    # else
    #   @topic_name.agency_assigned = false
    # end
    
    @topic_name.save!
    flash[:notice] = 'Successfully saved'
    
    next_topic_name = TopicName.unprocessed.first
    if next_topic_name
      redirect_to edit_admin_topic_name_path(next_topic_name)
    else
      redirect_to unprocessed_admin_topic_names_path
    end
  end
end