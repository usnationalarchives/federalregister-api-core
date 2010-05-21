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
    @topic_names = TopicName.unprocessed.paginate(:page => params[:page])
  end
  
  def edit
    @topic_name = TopicName.find(params[:id])
  end
  
  def update
    @topic_name = TopicName.find(params[:id])
    if @topic_name.update_attributes(params[:topic_name])
      flash[:notice] = 'Successfully saved'
      next_topic_name = TopicName.unprocessed.first(:conditions => ["topic_names.name > ?", @topic_name.name])
      if next_topic_name
        redirect_to edit_admin_topic_name_path(next_topic_name)
      else
        redirect_to unprocessed_admin_topic_names_path
      end
    else
      flash.now[:error] = 'There was a problem.'
      render :action => :edit
    end
  end
end