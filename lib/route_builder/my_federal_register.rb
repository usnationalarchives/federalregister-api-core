module RouteBuilder::MyFederalRegister
  def my_fr2_clippings_path
    "/my/clippings"
  end

  def my_site_notifications_path(params)
    "/special/site_notifications/#{params[:identifier]}"
  end
end
