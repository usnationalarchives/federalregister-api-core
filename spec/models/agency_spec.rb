# == Schema Information
#
# Table name: agencies
#
#  id                          :integer(4)      not null, primary key
#  parent_id                   :integer(4)
#  name                        :string(255)
#  created_at                  :datetime
#  updated_at                  :datetime
#  slug                        :string(255)
#  agency_type                 :string(255)
#  short_name                  :string(255)
#  description                 :text
#  more_information            :text
#  entries_count               :integer(4)      default(0), not null
#  entries_1_year_weekly       :text
#  entries_5_years_monthly     :text
#  entries_all_years_quarterly :text
#  related_topics_cache        :text
#  logo_file_name              :string(255)
#  logo_content_type           :string(255)
#  logo_file_size              :integer(4)
#  logo_updated_at             :datetime
#  url                         :string(255)
#  active                      :boolean(1)
#  cfr_citation                :text
#  display_name                :string(255)
#

require 'spec_helper'

describe Agency do
  it { should have_many :entries }
  
  describe "named_approximately" do
    before(:each) do
      @nasa = Agency.create!(:name => "National Aeronautics and Space Administration", :short_name => "NASA")
      @commission = Agency.create!(:name => "Commission on the Future of the United States Aerospace Industry")
      @international = Agency.create!(:name => "Agency for International Development")
      @office = Agency.create!(:name => "Administrative Office of United States Courts")
      @prison = Agency.create!(:name => "Prison Bureau")
    end
    
    it "matches based on partial words" do
      Agency.named_approximately("Admin").should == [@office, @nasa]
    end
    
    it "ignores word order" do
      Agency.named_approximately("Administration Space").should == [@nasa]
    end
    
    it "matches short_names" do
      Agency.named_approximately("NASA").should == [@nasa]
    end
    
    it "ignores stop words" do
      Agency.named_approximately("National Aeronautics & Space Administration").should == [@nasa]
      Agency.named_approximately("The Administrative Office of United States Courts").should == [@office]
    end
    
    it "does not error out on numbers" do
      Agency.named_approximately("2979").should == []
    end
    
    after(:each) do
      Agency.connection.execute("TRUNCATE agencies")
    end
  end
end
