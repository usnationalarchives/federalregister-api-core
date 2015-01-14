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

  describe 'regulations_dot_gov_comments_close_on' do
    it "persists a date when no date exists" do
      date = Date.new(2013,1,1)
      entry = Entry.create!
      entry.regulations_dot_gov_comments_close_on = date
      entry.save!

      entry.reload
      entry.regulations_dot_gov_comments_close_on.should eql date
    end

    it "updates the date when a date already existed" do
      original_date = Date.current
      entry = Entry.create!
      entry.regulations_dot_gov_comments_close_on = original_date
      entry.save!

      entry.reload

      new_date = Date.new(2013,1,1)
      entry.regulations_dot_gov_comments_close_on = new_date
      entry.save!

      entry.reload

      entry.regulations_dot_gov_comments_close_on.should eql new_date
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
