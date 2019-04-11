class Admin::MissingImagesController < AdminController
  layout 'admin_bootstrap'

  def index
    @presenter = MissingImagesPresenter.new
  end

end

