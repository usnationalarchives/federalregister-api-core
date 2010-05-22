require 'spec_helper'

describe Content::EntryImporter::Sections do
  before(:each) do
    @agency_1 = Factory.create(:agency)
    @agency_2 = Factory.create(:agency)
    
    @entry = Factory.create(:entry, :cfr_title => "1", :cfr_part => "135", :agencies => [@agency_1])
    @importer = Content::EntryImporter.new(:entry => @entry)
  end
  
  it "assigns based on CFR title" do
    section_1 = Factory.create(:section, :relevant_cfr_sections => "1 CFR")
    section_2 = Factory.create(:section, :relevant_cfr_sections => "2 CFR")
    @importer.update_attributes(:section_ids)
    
    @entry.sections.should == [section_1]
  end
  
  it "assigns based on CFR part" do
    section_1 = Factory.create(:section, :relevant_cfr_sections => "1 CFR 100-199")
    section_2 = Factory.create(:section, :relevant_cfr_sections => "1 CFR 200-299")
    @importer.update_attributes(:section_ids)
    
    @entry.sections.should == [section_1]
  end
  
  it "assigns based on associated agency" do
    section_1 = Factory.create(:section, :agencies => [@agency_1])
    section_2 = Factory.create(:section, :agencies => [@agency_2])
    
    @importer.update_attributes(:section_ids)
    
    @entry.sections.should == [section_1]
  end
end