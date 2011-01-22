class SubscriptionsController < ApplicationController
  def new
    @subscription = Subscription.new(params[:subscription])
  end
  
  def create
    @subscription = Subscription.new(params[:subscription])
    
    if @subscription.save
      flash[:notice] = "Subscription saved"
      redirect_to root_url
    else
      render :action => :new
    end
  end
  
  def delete
    @subscription = Subscription.find_by_token!(params[:id])
  end
  
  def destroy
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.update(:unsubscribed_at => Time.current)
    flash[:notice] = "Successfully unsubscribed"
    redirect_to root_url
  end
end