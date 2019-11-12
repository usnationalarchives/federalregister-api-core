class Admin::MissingImagesController < AdminController
  def index
    @presenter = MissingImagesPresenter.new
  end

end

