require 'spec_helper'

describe EntryRegulationIdNumber do
  it { should belong_to :entry }
  it { should have_many :regulatory_plans }
end
