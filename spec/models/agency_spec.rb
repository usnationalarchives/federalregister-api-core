require 'spec_helper'

describe Agency do
  it { should have_many :entries }
end