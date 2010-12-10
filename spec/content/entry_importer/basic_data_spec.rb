require 'spec_helper'

describe Content::EntryImporter::BasicData do
  describe 'significant' do
    it "is true if any associated regulatory_plans are significant" do
      RegulatoryPlan.create!(:regulation_id_number => "ABCD-1234", :priority_category => 'Economically Significant', :issue => "201004")
      entry = Entry.create!(:regulation_id_numbers => ["ABCD-1234"])
      importer = Content::EntryImporter.new(:entry => entry)
      importer.update_attributes(:significant)
      entry.significant?.should be_true
    end
    
    it "is false if no associated regulatory_plans are significant" do
      entry = Entry.create!(:regulation_id_numbers => [])
      importer = Content::EntryImporter.new(:entry => entry)
      importer.update_attributes(:significant)
      entry.significant?.should be_false
    end
  end
end