module RouteBuilder::MyFederalRegister
  def my_fr2_shared_assets_path
    "/special/shared_assets"
  end

  def my_fr2_assets_path
    "/special/my_fr_assets"
  end

  def my_fr2_fr2_assets_path
    "/special/fr2_assets"
  end

  def my_fr2_clippings_path
    "/my/clippings"
  end

  def my_site_notifications_path(params)
    "/special/site_notifications/#{params[:identifier]}"
  end

  def my_fr2_navigation_path
    "/special/navigation"
  end

  def my_fr2_user_utils_path
    "/special/user_utils"
  end

  def my_fr2_header_path(header_type)
    "/special/header/#{header_type}"
  end

  def my_fr2_footer_path
    "/special/footer"
  end
end
