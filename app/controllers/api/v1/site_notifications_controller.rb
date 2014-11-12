class Api::V1::SiteNotificationsController < ApiController
  def show
    notification = SiteNotification.active.find_by_identifier(params[:id])
    if notification.present?
      render_json_or_jsonp(notification)
    else
      render :nothing => true, :status => 404
    end
  end
end
