class SubscriptionsController < ApplicationController
  # TODO: remove me
  skip_before_filter :verify_authenticity_token
  
  def new
    @subscription = Subscription.new(params[:subscription])
  end
  
  def create
    @subscription = Subscription.new(params[:subscription])
    
    @subscription.requesting_ip = request.remote_ip
    if @subscription.save
      redirect_to confirmation_sent_subscriptions_url
    else
      render :action => :new
    end
  end
  
  def confirmation_sent
  end
  
  def confirm
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.update_attributes!(:confirmed_at => Time.current)
    redirect_to confirmed_subscriptions_path
  end
  
  def confirmed
  end
  
  def unsubscribe
    @subscription = Subscription.find_by_token!(params[:id])
  end
  
  def destroy
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.update_attributes!(:unsubscribed_at => Time.current)
    redirect_to unsubscribed_subscriptions_url
  end
  
  def unsubscribed
  end
end