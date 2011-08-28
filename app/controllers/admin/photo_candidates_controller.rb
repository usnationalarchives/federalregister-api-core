class Admin::PhotoCandidatesController < AdminController
  def show
    tag_name = params[:id]
    photos = Flickr.new.search(tag_name)
    i = 0
    photos = photos.select do |photo|
      if i < 25 && photo.of_appropriate_size?
        i += 1
        true
      else
        false
      end
    end
    render :partial => "admin/photo_candidates/topic", :locals => {:topic => tag_name, :photos => photos}
  end
end
