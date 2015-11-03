require 'spec_helper'

describe AgencyNameAssignment do
  describe 'create' do
    it "creates agency_assignments if has agency_id" do
      entry = Factory(:entry)
      entry.agencies.size.should == 0
      AgencyNameAssignment.create(:assignable => entry, :agency_name => Factory(:agency_name))
      entry.agencies.size.should == 1
    end
  end

  describe 'destroy' do
    it "should destroy all associated agency_assignments" do
      entry = Factory(:entry)
      agency_name_assignment = AgencyNameAssignment.create(
        :assignable => entry,
        :agency_name => Factory(:agency_name)
      )
      entry.agencies.size.should == 1
      agency_name_assignment.destroy
      entry.agencies.size.should == 0
    end
  end
end
