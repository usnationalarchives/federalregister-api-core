class Admin::SiteNotificationsController < AdminController
  layout 'admin_bootstrap'

  def index
    @site_notifications = SiteNotification.all
  end

  def edit
    @site_notification = SiteNotification.find(params[:id])
  end

  def update
    @site_notification = SiteNotification.find(params[:id])
    if @site_notification.update_attributes(params[:site_notification])
      flash[:notice] = "Site notification updated"
      redirect_to admin_site_notifications_path
    else
      flash.now[:error] = "There was a problem"
      render :action => :edit
    end
  end
end
