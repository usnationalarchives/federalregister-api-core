require 'spec_helper'

describe Subscription do
  it { should belong_to(:mailing_list) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:requesting_ip) }
  
  it "should generate a random token on create" do
    s1 = Subscription.new
    s1.save(false)
    s2 = Subscription.new
    s2.save(false)
    
    s1.token.should be_present
    s1.token.should_not == s2.token
  end
  
  describe 'active?' do
    it 'is true if confirmed_at is present and unsubscribed_at is not' do
      Factory(:subscription, :confirmed_at => Time.now, :unsubscribed_at => nil).active?.should be_true
    end
    
    it 'is false if confirmed_at is not present' do
      Factory(:subscription, :confirmed_at => nil).active?.should be_false
    end
    
    it 'is false if unsubscribed_at is present' do
      Factory(:subscription, :confirmed_at => Time.now, :unsubscribed_at => Time.now).active?.should be_false
    end
  end
  
  describe "updating mailing_lists.active_subscriptions_count" do
    it "does not change the active_subscriptions_count when a non-confirmed subscription is created" do
      mailing_list = Factory(:mailing_list)
      expect{ Factory(:subscription, :mailing_list => mailing_list, :confirmed_at => nil) }.to_not change{mailing_list.active_subscriptions_count}
    end
    
    it "increases the active_subscriptions_count when a non-confirmed subscription is confirmed" do
      mailing_list = Factory(:mailing_list)
      subscription = Factory(:subscription, :mailing_list => mailing_list, :confirmed_at => nil, :unsubscribed_at => nil)
      
      expect{ subscription.update_attributes(:confirmed_at => Time.now) }.to change{mailing_list.reload; mailing_list.active_subscriptions_count}.from(0).to(1)
    end
    
    it "decreases the active_subscriptions_count when a confirmed subscription is unsubscribed" do
      mailing_list = Factory(:mailing_list)
      subscription = Factory(:subscription, :mailing_list => mailing_list, :confirmed_at => Time.now, :unsubscribed_at => nil)
      mailing_list.reload
      
      expect{ subscription.update_attributes(:unsubscribed_at => Time.now) }.to change{mailing_list.reload; mailing_list.active_subscriptions_count}.from(1).to(0)
    end
  end
  
  describe 'parameters=' do
  end
  
  describe 'mailing_list' do
    it "should be created on subscription create if it does not exist" do
      subscription = Factory(:subscription, :parameters => "{}")
      subscription.mailing_list.parameters.should == "{}"
    end
    
    it "should be associated on subscription create if it does exist" do
      subscription_1 = Factory(:subscription, :parameters => "{}")
      list_1 = subscription.mailing_list
      subscription_2 = Factory(:subscription, :parameters => "{}")
      subscription_2.mailing_list.should == list_1
    end
  end
end
