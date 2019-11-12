class Admin::Users::PasswordsController < AdminController
  def edit
    @user = User.find(params[:user_id])
  end

  def update
    @user = User.find(params[:user_id])
    if @user.valid_password?(params[:user][:current_password])
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if params[:user][:password].blank?
        flash.now[:error] = "You must enter a new password."
        render :action => :edit
      else
        if @user.save
          flash[:notice] = "Password successfully changed."
          redirect_to admin_home_url
        else
          flash.now[:error] = "There was a problem changing your password."
          render :action => :edit
        end
      end
    else
      flash.now[:error] = "Your current password is incorrect."
      render :action => :edit
    end
  end
end
