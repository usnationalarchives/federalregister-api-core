require 'spec_helper'

describe AgencyNameAssignment do
  before(:each) do
    ElasticsearchIndexer.stub(:handle_entry_changes)
  end

  describe 'create' do
    it "Agencies are implicitly associated with entries via agency name assignments" do
      entry = Factory(:entry)
      entry.agencies.size.should == 0
      AgencyNameAssignment.create(:assignable => entry, :agency_name => Factory(:agency_name))
      entry.reload.agencies.size.should == 1
    end
  end

end
