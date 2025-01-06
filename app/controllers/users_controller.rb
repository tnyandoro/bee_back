class UsersController < ApplicationController
  include Pagy::Backend

  before_action :set_organization
  before_action :set_user, only: %i[show update destroy]
  before_action :authorize_admin, only: %i[create update destroy]

  # GET /users
  def index
    if params[:role] && !User.roles.key?(params[:role])
      render json: { error: 'Invalid role' }, status: :unprocessable_entity
      return
    end

    @pagy, @users = pagy(@organization.users.filter_by_role(params[:role]))
    render json: {
      users: UserSerializer.new(@users).serializable_hash,
      pagy: pagy_metadata(@pagy)
    }
  end

  # GET /users/1
  def show
    render json: UserSerializer.new(@user).serializable_hash
  end

  # POST /users
  def create
    @user = @organization.users.new(user_params)

    # Prevent non-admins from creating admins
    if user_params[:role] == 'admin' && !current_user.role_admin?
      render json: { error: 'You are not authorized to create an admin user' }, status: :forbidden
      return
    end

    if @user.save
      render json: UserSerializer.new(@user).serializable_hash, status: :created, location: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    # Prevent non-admins from updating users to admin
    if user_params[:role] == 'admin' && !current_user.role_admin?
      render json: { error: 'You are not authorized to update this user to admin' }, status: :forbidden
      return
    end

    if @user.update(user_params)
      render json: UserSerializer.new(@user).serializable_hash
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
    head :no_content
  end

  private

  # Identify organization using subdomain
  def set_organization
    @organization = Organization.find_by!(subdomain: request.subdomain)
  end

  # Use callbacks to share common setup or constraints between actions
  def set_user
    @user = @organization.users.find_by(id: params[:id])
    render json: { error: 'User not found' }, status: :not_found unless @user
  end

  # Only allow a list of trusted parameters through
  def user_params
    params.require(:user).permit(:name, :email, :password, :role, :department, :position)
  end

  # Ensure only admins can perform certain actions

  def authorize_admin
    unless current_user&.role_admin? || (current_user&.role_teamlead? && @user&.role_agent? || @user&.role_viewer?)
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
    end
  end
end
