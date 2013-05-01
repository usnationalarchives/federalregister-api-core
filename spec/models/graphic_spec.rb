require 'spec_helper'

describe Graphic do
  it { should have_many(:usages) }
  it { should have_many(:entries) }
end
