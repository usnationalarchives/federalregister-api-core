require 'spec_helper'

describe MailingList do
  it { should validate_presence_of(:parameters) }
  it { should validate_presence_of(:title) }
end
