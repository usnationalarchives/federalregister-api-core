class FrFlickrPhoto
  def self.search(text)
    conditions = {
      :text => text,
      :license => '1,2,4,5,7,8',
      :per_page => 150
    }

    relevant = Flickr::Photo.search(
      conditions.merge :sort => 'relevance'
    )

    interesting = Flickr::Photo.search(
      conditions.merge :sort => 'interestingness-desc'
    )

    relevant_and_interesting_ids = relevant.map(&:id) & interesting.map(&:id)

    (
      relevant.select{|photo|
        relevant_and_interesting_ids.include?(photo.id)
      } + relevant
    ).uniq
  end

  def self.person(photo_id)
    Flickr::Person.find(:photo_id => photo_id)
  end
end
