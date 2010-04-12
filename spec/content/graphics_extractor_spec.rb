require 'spec_helper'

describe Content::GraphicsExtractor do
  before(:each) do 
    @extractor = Content::GraphicsExtractor.new('2010-04-01')
  end
  
  describe "#images" do
    before :each do
      @extractor.stub(:entry_bulkdata_path).and_return("#{Rails.root}/spec/fixtures/content/graphics_extractor.xml")
    end
    
    it "should find all the images" do
      @extractor.images.size.should == 3
    end
    
    it "should have the correct identifier for each image" do
      @extractor.images.first.identifier.should  == 'FIRST.000'
      @extractor.images.second.identifier.should == 'SECOND.000'
      @extractor.images.third.identifier.should  == 'THIRD.000'
    end
  end
  
  describe "#perform" do
    before :each do
      @extractor.stub(:entry_bulkdata_path).and_return("#{Rails.root}/spec/fixtures/content/graphics_extractor.xml")
    end
    
    # it "should process each image" do
    #   @extractor.should_receive(:process_image).with(@extractor.images.first)
    #   @extractor.should_receive(:process_image).with(@extractor.images.second)
    #   @extractor.perform
    # end
  end
end

