module RouteBuilder::MyFederalRegister
  def my_fr2_shared_assets_path
    "/my/special/shared_assets"
  end

  def my_fr2_assets_path
    "/my/special/my_fr_assets"
  end

  def my_fr2_fr2_assets_path
    "/my/special/fr2_assets"
  end

  def my_fr2_clippings_path
    "/my/clippings"
  end

  def my_site_notifications_path(params)
    "/my/special/site_notifications/#{params[:identifier]}"
  end
end
