require "spec_helper"

describe 'ApplicationSearch::PlaceSelector' do
  it 'errors out if within is greater than 200' do
    place_selector = ApplicationSearch::PlaceSelector.new('94118', 250)
    place_selector.validation_errors.should_not be_empty
  end
  
  it 'errors out if within is less than 1' do
    place_selector = ApplicationSearch::PlaceSelector.new('94118', '0')
    place_selector.validation_errors.should_not be_empty
  end
  
  it 'adds an error if an invalid message is provided' do
    place_selector = ApplicationSearch::PlaceSelector.new('Crazy Unknown Non-Existent Place')
    place_selector.place_ids
    place_selector.validation_errors.should_not be_empty
  end
  
  it 'finds the nearby places' do
    place = Factory(:place, :name => "San Francisco, CA, US", :latitude => '37.7792', :longitude => '-122.42')
    place_selector = ApplicationSearch::PlaceSelector.new('94118')
    place_selector.place_ids.should == [place.id]
  end
end