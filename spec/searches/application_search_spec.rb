require "spec_helper"

describe EsApplicationSearch, vcr: true do

  before(:each) do
    @search_class = Class.new(EsApplicationSearch)
    allow(@search_class)
  end

  describe 'define_filter' do
    before(:each) do
      @search_class.define_filter(:topic_id) {|x| x}
    end

    it "creates an instance setter method" do
      @search_class.new.should respond_to :topic_id=
    end

    it "creates an instance getter method" do
      @search_class.new.should respond_to :topic_id
    end

    it "adds a filter when used" do
      search = @search_class.new
      search.topic_id = 1
      search.filters.size.should == 1
    end
  end

  describe 'define_place_filter' do
    before(:each) do
      @search_class.define_place_filter :near, :es_attribute => :place_ids
    end

    it "creates an instance setter method" do
      @search_class.new.should respond_to :near=
    end

    it "creates an instance getter method" do
      @search_class.new.should respond_to :near
    end

    #TODO: uncomment when merging new geolocation code
    # it "adds a filter when used" do
    #   place = Factory(:place, :name => "San Francisco, CA, US", :latitude => '37.7792', :longitude => '-122.42')
    #
    #   search = @search_class.new
    #   search.near = {:location => "94118", :within => "50"}
    #   search.filters.size.should == 1
    # end
  end
end
