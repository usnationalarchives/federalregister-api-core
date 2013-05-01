require 'spec_helper'

describe AgencyName do
  describe 'destroy' do
    it "destroys all related agency_name_assignments" do
      AgencyNameAssignment.count == 0
      agency_name = Factory(:agency_name)
      Factory(:entry, :agency_names => [agency_name])
      AgencyNameAssignment.count == 1
      agency_name.destroy
      AgencyNameAssignment.count == 0
    end
    
    it "destroys all related agency_assignments" do
      AgencyAssignment.count == 0
      agency_name = Factory(:agency_name)
      Factory(:entry, :agency_names => [agency_name])
      AgencyAssignment.count == 1
      agency_name.destroy
      AgencyAssignment.count == 0
    end
  end
  
  describe 'update' do
    it "creates agency_assignments when agency_id is added" do
      agency = Factory(:agency)
      agency_name = Factory(:agency_name, :agency_id => nil)
      entry = Factory(:entry, :agency_names => [agency_name])
      entry.agencies.should == []
      
      agency_name.update_attributes(:agency_id => agency.id)
      entry.reload
      entry.agencies.should == [agency]
    end
    
    it "creates agency_assignments when agency_id is added, setting position correctly" do
      agency_1 = Factory(:agency)
      agency_2 = Factory(:agency)
      agency_name_1 = Factory(:agency_name, :agency_id => nil)
      agency_name_2 = Factory(:agency_name, :agency_id => nil)
      
      entry = Factory(:entry, :agency_names => [agency_name_2, agency_name_1])
      entry.agencies.should == []
      
      agency_name_1.update_attributes(:agency_id => agency_1.id)
      agency_name_2.update_attributes(:agency_id => agency_2.id)
      entry.reload
      entry.agencies.should == [agency_2, agency_1]
      entry.agency_assignments.map(&:position) == [1,2]
    end
    
    it "modifies agency_assignments when agency_id changes" do
      agency_1 = Factory(:agency)
      agency_name = Factory(:agency_name, :agency => agency_1)
      entry = Factory(:entry, :agency_names => [agency_name])
      entry.agencies.should == [agency_1]
      
      agency_2 = Factory(:agency)
      agency_name.update_attributes!(:agency => agency_2)
      entry.reload
      entry.agencies.should == [agency_2]
    end
    
    it "removes agency_assignments when agency_id is cleared" do
      agency_1 = Factory(:agency)
      agency_name = Factory(:agency_name, :agency => agency_1)
      entry = Factory(:entry, :agency_names => [agency_name])
      entry.agencies.should == [agency_1]
      
      agency_name.update_attributes!(:agency => nil)
      entry.reload
      entry.agencies.should == []
    end

    it "recalculates agency.entries_count when agency_id is set" do
      agency = Factory(:agency)
      agency_name = Factory(:agency_name, :agency => agency)
      entry = Factory(:entry, :agency_names => [agency_name])
      agency.reload
      agency.entries_count.should == 1
    end
    
    it "recalculates agency.entries_count when agency_id changes" do
      agency_1 = Factory(:agency)
      agency_name = Factory(:agency_name, :agency => agency_1)
      entry = Factory(:entry, :agency_names => [agency_name])
      agency_2 = Factory(:agency)
      agency_name.update_attributes(:agency => agency_2)
      agency_1.reload
      agency_2.reload
      agency_1.entries_count.should == 0
      agency_2.entries_count.should == 1
    end
  end
  
end
