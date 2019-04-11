require 'spec_helper'

describe AgencyAssignment do
  describe 'updating of agency entries_count counter_cache' do
    it "increments the counter_cache when an entry agency_assignment is created" do
      agency = Factory(:agency)
      entry = Factory(:entry)

      expect{AgencyAssignment.create(:assignable => entry, :agency => agency); agency.reload}.to change{agency.entries_count}.from(0).to(1)
    end

    it "decrements the counter_cache when an entry agency_assignment is destroyed" do
      agency = Factory(:agency)
      entry = Factory(:entry)
      assignment = AgencyAssignment.create(:assignable => entry, :agency => agency)
      agency.reload

      expect{assignment.destroy; agency.reload}.to change{agency.entries_count}.from(1).to(0)
    end

    it "does not change the counter_cache when a regulation agency_assignment is created" do  
      agency = Factory(:agency)
      regulatory_plan = Factory(:regulatory_plan)

      expect{AgencyAssignment.create(:assignable => regulatory_plan, :agency => agency); agency.reload}.to_not change{agency.entries_count}
    end

    it "does not change the counter_cache when a regulation agency_assignment is destroyed" do
      agency = Factory(:agency)
      regulatory_plan = Factory(:regulatory_plan)
      assignment = AgencyAssignment.create(:assignable => regulatory_plan, :agency => agency)
      agency.reload

      expect{ assignment.destroy; agency.reload}.to_not change{agency.entries_count}
    end
  end
end
