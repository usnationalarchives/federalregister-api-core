require 'spec_helper'

describe Section do
  it { should have_many(:agencies_sections) }
  it { should have_many(:agencies) }
end
