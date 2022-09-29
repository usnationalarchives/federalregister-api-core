require 'spec_helper'

describe Entry do
  describe "regulation_id_numbers=" do
    it "creates associated entry_regulation_id_numbers when no exist" do
      rins = ["ABCD-1234", "ABCD-5678"]
      e = Entry.new(:regulation_id_numbers => rins)
      e.save!
      e.reload
      e.entry_regulation_id_numbers.map(&:regulation_id_number).should == rins
    end

    it "removes entry_regulation_id_numbers when not passed" do
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
    it 'finds nothing when no RIN associated' do
      e = Entry.create!()
      e.current_regulatory_plans.should == []
    end

    it 'finds nothing if the associated RIN is not included in the current issue' do
      something_in_current_issue = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1111", :current => true)
      something_in_prior_issue = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1234", :current => false)
      e = Entry.create!(:regulation_id_numbers => [something_in_prior_issue.regulation_id_number])
      e.current_regulatory_plans.should == []
    end

    it 'finds the regulatory_plan if the associated RIN is included in the current issue' do
      prior = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1234", :current => false)
      cur = RegulatoryPlan.create!(:regulation_id_number => "ABCD-1234", :current => true)
      e = Entry.create!(:regulation_id_numbers => [cur.regulation_id_number])
      e.current_regulatory_plans.should == [cur]
    end
  end


  describe 'slug' do
    it "downcases" do
      Entry.new(:title => "Meeting").slug.should == 'meeting'
    end

    it "converts non-alphanumeric characters to dashes" do
      Entry.new(:title => "Proposed Rule").slug.should == 'proposed-rule'
    end

    it "omits dashes at beginning and end" do
      Entry.new(:title => "[Amended]").slug.should == 'amended'
    end

    it "converts ampersands to 'and'" do
      Entry.new(:title => "Foo & Bar").slug.should == 'foo-and-bar'
    end

    it "retains dashes" do
      Entry.new(:title => "Albany-Eugene Transmission Line").slug.should == 'albany-eugene-transmission-line'
    end

    it "limits the length to 100 characters" do
      Entry.new(:title => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt unt labore et dolore magna aliqua.").slug.should ==
        'lorem-ipsum-dolor-sit-amet-consectetur-adipisicing-elit-sed-do-eiusmod-tempor-incididunt-unt-labore'
    end

    it "does not truncate in the middle of a word" do
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
    it "removes all agency_name_assignments" do
      ElasticsearchIndexer.stub(:handle_entry_changes)
      entry = Factory(:entry, :agency_names => [Factory(:agency_name), Factory(:agency_name)])
      AgencyNameAssignment.count.should == 2
      entry.destroy
      AgencyNameAssignment.count.should == 0
    end

    it "removes all topic_name_assignments" do
      entry = Factory(:entry, :topic_names => [Factory(:topic_name), Factory(:topic_name)])
      TopicNameAssignment.count.should == 2
      entry.destroy
      TopicNameAssignment.count.should == 0
    end

    it "removes all topic_assignments" do
      entry = Factory(:entry, :topic_names => [Factory(:topic_name, :topics => [Factory(:topic)]), Factory(:topic_name, :topics => [Factory(:topic), Factory(:topic)])])
      TopicAssignment.count.should == 3
      entry.destroy
      TopicAssignment.count.should == 0
    end
  end

  describe "recording of entry changes" do
    it "records an entry in the entry changes table on update if one does not exist" do
      entry = Factory(:entry)
      entry.update!(title: 'foo')

      expect(EntryChange.first.entry_id).to eq(entry.id)
    end

    it "does not create a duplicate record if an entry change record already exists" do
      entry = Factory(:entry)
      entry.update!(title: 'foo')
      entry.update!(title: 'bar')

      expect(EntryChange.count).to eq(1)
    end

    it "creates an entry change record if a record is deleted" do
      entry = Factory(:entry)
      EntryChange.delete_all
      entry.reload.destroy!

      expect(EntryChange.count).to eq(1)
      expect(EntryChange.first.entry_id).to eq(entry.id)
    end

    it "does not create a duplicate record if an entry change record already exists" do
      entry = Factory(:entry)
      entry.update!(title: 'foo')
      entry_id = entry.id
      entry.destroy!

      expect(EntryChange.count).to eq(1)
      expect(EntryChange.first.entry_id).to eq(entry_id)
    end

  end

  describe "regulations.gov attributes" do
    it "parses regulations_dot_gov_agency_id with underscores AND hyphens" do
      entry = Entry.new(regulations_dot_gov_document_id: 'DOE_FRDOC_0001-4278')
      expect(entry.regulations_dot_gov_agency_id).to eq('DOE')

    end

    it "parses regulations_dot_gov_agency with with" do
      entry = Entry.new(regulations_dot_gov_document_id: 'CDC-2021-0106-0048')
      expect(entry.regulations_dot_gov_agency_id).to eq('CDC')
    end
  end
end
