class UsersController < ApplicationController

    before_filter :signed_in_user, only:[:edit, :update, :index, :destroy]
    before_filter :correct_user,   only:[:edit, :update] 
    before_filter :admin_user,     only:[:destroy] 
    before_filter :already_signed_in,  only:[:new, :create] 

  include SessionsHelper

  def index
    @users = User.paginate(page: params[:page])
  end

  def new
     @user = User.new
  end

  def show
      @user = User.find(params[:id])
      @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
      @user = User.new(params[:user])
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
      else
        render 'new'
      end
  end

  def edit
  end

  def update
      if @user.update_attributes(params[:user])
        #success
        flash[:success] = "Profile updated"
        sign_in @user
        redirect_to @user
     else
        #error
        render 'edit'
     end
  end

  def destroy
    @user = User.find(params[:id])
    if current_user?(@user)
        flash[:notice] = 'You cannot destroy yourself'
        redirect_to users_url
        return
    end
    @user.destroy
    flash[:success] = 'User destroyed.'
    redirect_to users_url
  end


  private

    def correct_user
        @user = User.find(params[:id])
        redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
        redirect_to(root_path) unless current_user.admin?
    end

    def already_signed_in
      redirect_to(root_path) and return if current_user
   end
end
