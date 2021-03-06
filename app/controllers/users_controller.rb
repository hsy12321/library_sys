class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :show]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  def new
    @user = User.new
  end
  
  def index
     @users = User.paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
     @rooms = Room.where(:booker =>"#{ @user.id }" )
     @histories= History.where(:user_id =>"#{ @user.id }" )
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      if current_user.nil?
        log_in @user
        flash[:success] = "Welcome to the NCSU Library!"
        redirect_to @user
      else
       flash[:success] = "have create the User/Admin"
       redirect_to @user
      end
    else
      render 'new'
    end
  end
  
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def adminlist
    list=User.where(:admin => true)
    @users=list.paginate(page: params[:page])
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :haveroom, :admin, :topadmin)
    end
    
    # 事前过滤器

    # 确保用户已登录
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
    
    # 确保是正确的用户
  def correct_user
      @user = User.find(params[:id])
     redirect_to(root_url) unless current_user?(@user) || current_user.admin?
  end
  
  # 确保是管理员
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

   
end
