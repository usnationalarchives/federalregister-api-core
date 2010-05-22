require 'spec_helper'

describe Content::EntryImporter::PageNumber do
  before(:each) do
    bulkdata_fixture = "#{Rails.root}/spec/fixtures/content/entry_importer/page_number.xml"
    @bulkdata_root = Nokogiri::XML(open(bulkdata_fixture)).root
  end
  
  context "multi-page document starting on its own page" do
    before(:each) do
      bulkdata_node = @bulkdata_root.xpath('.//RULE[1]').first
      @importer = Content::EntryImporter.new(:date => Date.today, :document_number => "ABC-001", :mods_node => true, :bulkdata_node => bulkdata_node)
    end
    
    describe ".start_page" do
      it "should find the first page node within the document" do
        @importer.start_page.should == 101
      end
      it "should find the last page node within the document" do
        @importer.end_page.should == 102
      end
    end
  end
  
  context "single-page document neither starting nor ending on its own page" do
    before(:each) do
      bulkdata_node = @bulkdata_root.xpath('.//RULE[2]').first
      @importer = Content::EntryImporter.new(:date => Date.today, :document_number => "ABC-002", :mods_node => true, :bulkdata_node => bulkdata_node)
    end
    
    describe ".start_page" do
      it "should find the last page node before the document" do
        @importer.start_page.should == 102
      end
      it "should find the last page node after the document" do
        @importer.end_page.should == 102
      end
    end
  end
  
  context "multi-page document not starting on its own page" do
    before(:each) do
      bulkdata_node = @bulkdata_root.xpath('.//RULE[3]').first
      @importer = Content::EntryImporter.new(:date => Date.today, :document_number => "ABC-003", :mods_node => true, :bulkdata_node => bulkdata_node)
    end
    
    describe ".start_page" do
      it "should find the first page node before the document" do
        @importer.start_page.should == 102
      end
      it "should find the last page node in the document" do
        @importer.end_page.should == 103
      end
    end
  end
end