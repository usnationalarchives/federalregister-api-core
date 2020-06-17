class Api::V1::SiteNotificationsController < ApiController
  def show
    cache_for 1.day

    notification = SiteNotification.find_by_identifier(params[:id])
    if notification.present?
      if notification.active?
        render_json_or_jsonp(notification)
      else
        render json: {}
      end
    else
      head 404
    end
  end
end
