class Admin::MissingImagesController < AdminController
  def index
    @presenter = MissingImagesPresenter.new
  end

  def show
    # This route is used for generating signed S3 urls for private objects
    image = Image.find_by_identifier(params[:id])
    if image
      if image.made_public_at.blank?
        image.fog_public = false #Calling fog_public = false causes image_file.url to generate a signed URL.
      end
      redirect_to image.image_file.url
    else
      redirect_to admin_missing_images_path
    end
  end

end

