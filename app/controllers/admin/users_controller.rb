class Admin::UsersController < AdminController
  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:notice] = "User created successfully."
      redirect_to admin_users_url
    else
      render :action => :new
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated successfully."
      redirect_to admin_users_url
    else
      render :action => :edit
    end
  end
end