class Admin::UserSessionsController < AdminController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  skip_before_filter :verify_authenticity_token

  def new
    @user_session = UserSession.new
  end

  def create
    user = User.find_by_email(params[:user_session][:email].to_s)
    if user && user.failed_login_count >= 10
      flash[:error] = "Too many failed login attempts; please contact an administrator to regain access."
      redirect_to new_admin_user_session_url
      return
    end

    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default admin_home_url
    else
      flash.now[:error] = "Invalid username or password."
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_admin_user_session_url
  end
end
