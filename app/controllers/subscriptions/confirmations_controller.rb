class Subscriptions::ConfirmationsController
  def new
    @subscription = Subscription.find_by_token!(params[:id])
  end
  
  def create
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.update(:confirmed_at => Time.current)
    flash[:notice] = "Successfully subscribed"
    redirect_to root_url
  end
end