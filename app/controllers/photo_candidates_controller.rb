class PhotoCandidatesController < AdminController
  def show
    tag_name = params[:id]
    photos = Flickr.new.search(tag_name)
    render :partial => "admin/photo_candidates/topic", :locals => {:topic => tag_name, :photos => photos}
  end
end