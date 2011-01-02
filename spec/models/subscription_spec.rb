require 'spec_helper'

describe Subscription do
  it "should generate a random token on create" do
    s1 = Subscription.new
    s1.save(false)
    s2 = Subscription.new
    s2.save(false)
    
    s1.token.should be_present
    s1.token.should_not == s2.token
  end
  
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:requesting_ip) }
end
