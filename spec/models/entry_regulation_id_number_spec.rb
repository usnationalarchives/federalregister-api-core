=begin Schema Information

 Table name: entry_regulation_id_numbers

  id                   :integer(4)      not null, primary key
  entry_id             :integer(4)
  regulation_id_number :string(255)

=end Schema Information

require 'spec_helper'

describe EntryRegulationIdNumber do
  it { should belong_to :entry }
  it { should have_many :regulatory_plans }
end
