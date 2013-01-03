# == Schema Information
#
# Table name: entries
#
#  id                            :integer(4)      not null, primary key
#  title                         :text
#  abstract                      :text
#  contact                       :text
#  dates                         :text
#  action                        :text
#  type                          :string(255)
#  link                          :string(255)
#  genre                         :string(255)
#  part_name                     :string(255)
#  citation                      :string(255)
#  granule_class                 :string(255)
#  document_number               :string(255)
#  toc_subject                   :string(1000)
#  toc_doc                       :string(1000)
#  length                        :integer(4)
#  start_page                    :integer(4)
#  end_page                      :integer(4)
#  publication_date              :date
#  places_determined_at          :datetime
#  created_at                    :datetime
#  updated_at                    :datetime
#  slug                          :text
#  delta                         :boolean(1)      default(TRUE), not null
#  source_text_url               :string(255)
#  regulationsdotgov_url         :string(255)
#  comment_url                   :string(255)
#  checked_regulationsdotgov_at  :datetime
#  volume                        :integer(4)
#  full_xml_updated_at           :datetime
#  citing_entries_count          :integer(4)      default(0)
#  document_file_path            :string(255)
#  full_text_updated_at          :datetime
#  curated_title                 :string(255)
#  curated_abstract              :string(500)
#  lede_photo_id                 :integer(4)
#  lede_photo_candidates         :text
#  raw_text_updated_at           :datetime
#  significant                   :boolean(1)
#  presidential_document_type_id :integer(4)
#  signing_date                  :date
#  executive_order_number        :integer(4)
#  action_name_id                :integer(4)
#  correction_of_id              :integer(4)
#  regulations_dot_gov_docket_id :string(255)
#  executive_order_notes         :text
#  fr_index_subject              :string(255)
#  fr_index_doc                  :string(255)
#

require 'spec_helper'

describe Entry do
  it { should have_many :entry_regulation_id_numbers }
  
  describe "regulation_id_numbers=" do
    it "should create associated entry_regulation_id_numbers when no exist" do
      rins = ["ABCD-1234", "ABCD-5678"]
      e = Entry.new(:regulation_id_numbers => rins)
      e.save!
      e.reload
      e.entry_regulation_id_numbers.map(&:regulation_id_number).should == rins
    end
    
    it "should remove entry_regulation_id_numbers when not passed" do
      e = Entry.new(:regulation_id_numbers => ["ABCD-1234", "ABCD-5678"])
      e.save!
      e.reload
      e.regulation_id_numbers = ["ABCD-1234"]
      e.save!
      e.reload
      
      e.entry_regulation_id_numbers.map(&:regulation_id_number).should == ["ABCD-1234"]
    end
  end
  
  describe "current_regulatory_plans" do
    it 'should find nothing when no RIN associated' do
      e = Entry.create!()
      e.current_regulatory_plans.should == []
    end
    
    it 'should find nothing if the associated RIN is not included in the current issue' do
      something_in_current_issue = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1111", :current => true)
      something_in_prior_issue = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1234", :current => false)
      e = Entry.create!(:regulation_id_numbers => [something_in_prior_issue.regulation_id_number])
      e.current_regulatory_plans.should == []
    end
    
    it 'should find the regulatory_plan if the associated RIN is included in the current issue' do
      prior = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1234", :current => false)
      cur = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1234", :current => true)
      e = Entry.create!(:regulation_id_numbers => [cur.regulation_id_number])
      e.current_regulatory_plans.should == [cur]
    end
  end
  
  
  describe 'slug' do
    it "should downcase" do
      Entry.new(:title => "Meeting").slug.should == 'meeting'
    end
    
    it "should convert non-alphanumeric characters to dashes" do
      Entry.new(:title => "Proposed Rule").slug.should == 'proposed-rule'
    end
    
    it "should omit dashes at beginning and end" do
      Entry.new(:title => "[Amended]").slug.should == 'amended'
    end
    
    it "should convert ampersands to 'and'" do
      Entry.new(:title => "Foo & Bar").slug.should == 'foo-and-bar'
    end
    
    it "should retain dashes" do
      Entry.new(:title => "Albany-Eugene Transmission Line").slug.should == 'albany-eugene-transmission-line'
    end
    
    it "should limit the length to 100 characters" do
      Entry.new(:title => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt unt labore et dolore magna aliqua.").slug.should ==
        'lorem-ipsum-dolor-sit-amet-consectetur-adipisicing-elit-sed-do-eiusmod-tempor-incididunt-unt-labore'
    end
    
    it "should not truncate in the middle of a word" do
      Entry.new(:title => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed unt eiusmod tempor incididunt labore cumin").slug.should == 'lorem-ipsum-dolor-sit-amet-consectetur-adipisicing-elit-sed-unt-eiusmod-tempor-incididunt-labore'
    end
  end
  
  describe 'destroy' do
    it "should remove all agency_name_assignments" do
      entry = Factory(:entry, :agency_names => [Factory(:agency_name), Factory(:agency_name)])
      AgencyNameAssignment.count.should == 2
      entry.destroy
      AgencyNameAssignment.count.should == 0
    end
    
    it "should remove all agency_assignments" do
      entry = Factory(:entry, :agency_names => [Factory(:agency_name), Factory(:agency_name)])
      AgencyAssignment.count.should == 2
      entry.destroy
      AgencyAssignment.count.should == 0
    end
    
    it "should remove all topic_name_assignments" do
      entry = Factory(:entry, :topic_names => [Factory(:topic_name), Factory(:topic_name)])
      TopicNameAssignment.count.should == 2
      entry.destroy
      TopicNameAssignment.count.should == 0
    end
    
    it "should remove all topic_assignments" do
      entry = Factory(:entry, :topic_names => [Factory(:topic_name, :topics => [Factory(:topic)]), Factory(:topic_name, :topics => [Factory(:topic), Factory(:topic)])])
      TopicAssignment.count.should == 3
      entry.destroy
      TopicAssignment.count.should == 0
    end
  end
end
