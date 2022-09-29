require 'spec_helper'

describe Content::EntryImporter::Sections do
  before(:each) do
    @agency_name_1 = Factory.create(:agency_name)
    @agency_name_2 = Factory.create(:agency_name)
    @agency_1      = @agency_name_1.agency
    @agency_2      = @agency_name_2.agency

    @entry = Factory.create(:entry, :entry_cfr_references => [EntryCfrReference.new(:title => 1, :part => 135)])
    AgencyNameAssignment.create!(
      agency_name_id:  @agency_name_1.id,
      assignable_id:   @entry.id,
      assignable_type: Entry
    )
    
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
