class Admin::PhotoCandidatesController < AdminController
  def show
    search_text = params[:id]
    photos = FrFlickrPhoto.search(search_text)
    i = 0
    photos = photos.select do |photo|
      if i < 144
        i += 1
        true
      else
        false
      end
    end

    render :json => photos
  end

  def info
    render :json => FrFlickrPhoto.person(params[:id])
  end
end
