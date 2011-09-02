=begin Schema Information

 Table name: subscriptions

  id                   :integer(4)      not null, primary key
  mailing_list_id      :integer(4)
  email                :string(255)
  requesting_ip        :string(255)
  token                :string(255)
  confirmed_at         :datetime
  unsubscribed_at      :datetime
  created_at           :datetime
  updated_at           :datetime
  last_delivered_at    :datetime
  delivery_count       :integer(4)      default(0)
  last_issue_delivered :date

=end Schema Information

require 'spec_helper'

describe Subscription do
  it { should belong_to(:mailing_list) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:requesting_ip) }
  it { should validate_presence_of(:environment) }
  
  it "should generate a random token on create" do
    s1 = Factory(:subscription)
    s2 = Factory(:subscription)
    
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
      
      expect{ subscription.confirmed_at = Time.now; subscription.save! }.to change{mailing_list.reload; mailing_list.active_subscriptions_count}.from(0).to(1)
    end
    
    it "decreases the active_subscriptions_count when a confirmed subscription is unsubscribed" do
      mailing_list = Factory(:mailing_list)
      subscription = Factory(:subscription, :mailing_list => mailing_list, :confirmed_at => Time.now, :unsubscribed_at => nil)
      mailing_list.reload
      
      expect{ subscription.unsubscribed_at = Time.now; subscription.save! }.to change{mailing_list.reload; mailing_list.active_subscriptions_count}.from(1).to(0)
    end
  end
  
  describe 'mailing_list' do
    it "should be created on subscription create if it does not exist" do
      subscription = Factory(:subscription, :search_conditions => {:term => "HAI"})
      subscription.mailing_list['search_conditions'].should == '{"term":"HAI"}'
    end
    
    it "should be associated on subscription create if it does exist" do
      subscription_1 = Factory(:subscription, :search_conditions => {:term => "HAI"})
      list_1 = subscription_1.mailing_list
      subscription_2 = Factory(:subscription, :search_conditions => {:term => "HAI"})
      subscription_2.mailing_list.should == list_1
    end
  end
  
  describe 'confirmation email' do
    it "should be sent after subscription is originally created" do
      subscription_1 = Factory.build(:subscription, :search_conditions => {:term => "HAI"})
      Mailer.should_receive(:deliver_subscription_confirmation).with(subscription_1)
      subscription_1.save!
    end
  end
end
