require 'spec_helper'

describe AgencyNameAssignment do
  before(:each) do
    ElasticsearchIndexer.stub(:handle_entry_changes)
  end

  describe 'create' do
    it "creates agency_assignments if has agency_id" do
      entry = Factory(:entry)
      entry.agencies.size.should == 0
      AgencyNameAssignment.create(:assignable => entry, :agency_name => Factory(:agency_name))
      entry.reload.agencies.size.should == 1
    end
  end

  describe 'destroy' do
    it "should destroy all associated agency_assignments" do
      pending("agency assignments need to be revisted")
      entry = Factory(:entry)
      agency_name_assignment = AgencyNameAssignment.create(
        :assignable => entry,
        :agency_name => Factory(:agency_name)
      )
      entry.reload.agencies.size.should == 1
      agency_name_assignment.destroy
      entry.reload.agencies.size.should == 0
    end
  end
end
