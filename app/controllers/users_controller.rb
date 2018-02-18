class UsersController < ApplicationController

  before_action :getLocaleCode
  before_action :find_user, only: [:show, :edit, :update]
  before_action :set_current_user_instance

  REGULAR_USER_PARAMS = [
    :email,
    :password,
    :password_confirmation,
    :given_name,
    :family_name,
    :govt_level,
    :govt_level_name,
    :municipality,
    :institute_type,
    :institute_name_loc,
    :position_type,
    :subject1,
    :subject2,
    :gender,
    :education_level,
    :work_phone,
    :work_address,
    :terms_accepted
  ]
  ADMIN_USER_PARAMS = [
    :role_admin,
    :role_teacher,
    :role_req_teacher
  ]

  def home
    @user = current_user
    @users = get_auth_users_list(true)
  end

  def index
    @users = get_auth_users_list
    if @users.count == 0
      redirect_to root_path
    else
      render :configuration
    end
  end

  def registrations
    unauthorized() and return if !user_is_admin?(current_user)
    @users = get_auth_users_list(true)
    render :configuration
  end

  def my_account
    unauthorized() and return if !user_is_admin?(current_user)
    render :configuration
  end

  def new
    unauthorized() and return if !user_is_admin?(current_user)
    @user = User.new()
    render :configuration
  end

  def create
    unauthorized() and return if !user_is_admin?(current_user)
    @user = User.new(admin_user_params)
    if @user.save
      flash[:success] = "user #{ @user.email } created."
    end
    render :configuration
  end

  def show
    # admins can view all, users can view themselves
    unauthorized() and return if !user_is_admin?(current_user) && !has_same_id?(current_user, @user)
    @users = get_auth_users_list(true)
    render :configuration
  end

  def edit
    # admins can edit all, users can edit themselves
    unauthorized() and return if !user_is_admin?(current_user) && !has_same_id?(current_user, @user)
    render :configuration
  end

  def update
    # admins can edit all, users can edit themselves
    unauthorized() and return if !user_is_admin?(current_user) && !has_same_id?(current_user, @user)
    if user_is_admin?(current_user)
      # regular user can set user as teacher or admin
      if @user.update(admin_user_params)
        flash[:success] = "user #{ @user.email } updated."
      end
    elsif has_same_id?(current_user, @user)
      # regular user cannot set self as teacher or admin
      if @user.update(regular_user_params)
        flash[:success] = "user #{ @user.email } updated."
      end
    end
    render :configuration
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def admin_user_params
    # do not allow roles to be passed through, must be done by role
    params.require('user').permit(REGULAR_USER_PARAMS.concat(ADMIN_USER_PARAMS))
  end

  def regular_user_params
    # do not allow roles to be passed through, must be done by role
    params.require('user').permit(REGULAR_USER_PARAMS)
  end

  def set_current_user_instance
    @current_user = current_user
  end

  def get_auth_users_list(unregistered_only = false)
    if user_is_admin?(current_user)
      if unregistered_only
        @users = User.all_unregistered.all
      else
        @users = User.all
      end
    else
      @users = []
    end
  end

end
