class Geokit::GeoLoc
  def name
    if city && state
      "#{city}, #{state}"
    elsif zip
      "#{zip}"
    elsif state
      "#{state}"
    end
  end
end