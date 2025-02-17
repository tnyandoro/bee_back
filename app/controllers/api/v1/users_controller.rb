# frozen_string_literal: true
module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_organization
      before_action :set_user, only: %i[show update destroy]
      before_action :authorize_admin, only: %i[create update destroy]

      # GET /organizations/:organization_id/users
      def index
        if params[:role] && !User.roles.key?(params[:role])
          render json: { error: 'Invalid role' }, status: :unprocessable_entity
          return
        end

        @users = @organization.users
        @users = @users.filter_by_role(params[:role]) if params[:role]
        @users = @users.filter_by_department(params[:department]) if params[:department]
        @users = @users.filter_by_position(params[:position]) if params[:position]
        @users = @users.filter_by_team(params[:team_id]) if params[:team_id]

        @users = @users.paginate(page: params[:page], per_page: 10) # Paginate with 10 items per page

        render json: {
          users: UserSerializer.new(@users).serializable_hash,
          pagination: {
            current_page: @users.current_page,
            total_pages: @users.total_pages,
            total_entries: @users.total_entries
          }
        }
      end

      # GET /users/1
      def show
        render json: UserSerializer.new(@user).serializable_hash
      end

      # POST /users
      def create
        @user = @organization.users.new(user_params)

        # Prevent non-admins from creating users
        unless current_user.role_admin?
          render json: { error: 'You are not authorized to create users' }, status: :forbidden
          return
        end

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

      # PATCH/PUT /users/1
      def update
        # Prevent non-admins from updating users
        unless current_user.role_admin?
          render json: { error: 'You are not authorized to update users' }, status: :forbidden
          return
        end

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
        # Prevent non-admins from deleting users
        unless current_user.role_admin?
          render json: { error: 'You are not authorized to delete users' }, status: :forbidden
          return
        end

        @user.destroy!
        head :no_content
      end

      private

      # Identify organization using organization_id or subdomain
      def set_organization
        if params[:organization_id]
          @organization = Organization.find(params[:organization_id])
        else
          @organization = Organization.find_by!(subdomain: request.subdomain)
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Organization not found' }, status: :not_found
      end

      # Use callbacks to share common setup or constraints between actions
      def set_user
        @user = @organization.users.find_by!(id: params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through
      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :department, :position, :team_id)
      end

      # Ensure only admins can perform certain actions
      def authorize_admin
        unless current_user&.role_admin?
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end

      # Get the current logged-in user
      def current_user
        @current_user ||= User.find_by(id: session[:user_id])
      end
    end
  end
end
