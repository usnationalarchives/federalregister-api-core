=begin Schema Information

 Table name: agency_names

  id         :integer(4)      not null, primary key
  name       :string(255)     not null
  agency_id  :integer(4)
  void       :boolean(1)
  created_at :datetime
  updated_at :datetime

=end Schema Information

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
  end
  
end
