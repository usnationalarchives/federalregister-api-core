require 'spec_helper'

describe Content::GraphicsExtractor::Image do
  before(:each) do
    @file_loc = "#{Rails.root}/spec/fixtures/content/graphics_extractor.xml"
    @images = Content::GraphicsExtractor::Image.all_images_in_file(@file_loc)
  end
  
  describe ".all_images_in_file" do
    it "should return all the associated images" do
      @images.size.should == 3
    end
  end
  
  describe "#identifier" do
    it "should take the GID element's content" do
      @images.first.identifier.should  == 'FIRST.000'
      @images.second.identifier.should == 'SECOND.000'
    end
  end

  describe "#page_number" do
    it "should look at the previous PRTPAGE element's P attribute" do
      @images.first.page_number.should  == 4658
      @images.second.page_number.should == 4659
    end
  end

  describe "#document_number" do
    it "should take the parent entry element's FRDOC's content and parse out the value" do
      @images.first.document_number.should  == '2010-1289'
      @images.second.document_number.should == '2010-1289'
    end
  end
  
  describe "#num_prior_images_on_page" do
    it "should count the prior images" do
      @images.first.num_prior_images_on_page.should  == 0
      @images.second.num_prior_images_on_page.should == 0
      @images.third.num_prior_images_on_page.should  == 1
    end
  end
end