class Admin::UsersController < AdminController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.attributes = user_params

    if @user.save
      flash[:notice] = "User created successfully. Please instruct the user to visit #{new_admin_password_reset_url} to set a password."
      redirect_to admin_users_path
    else
      render :action => :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      flash[:notice] = "User updated successfully."
      redirect_to admin_users_url
    else
      render :action => :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :active,
    )
  end
end
