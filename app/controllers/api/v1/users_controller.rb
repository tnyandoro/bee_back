# frozen_string_literal: true
module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_organization, except: [:profile] # Exclude profile from requiring explicit organization_id
      before_action :authenticate_user!, only: [:profile, :index, :show, :update, :destroy] # Add authentication for profile
      before_action :set_organization_from_subdomain, only: [:profile] # Use subdomain for profile
      before_action :verify_user_organization, only: [:profile] # Verify user belongs to organization
      before_action :set_user, only: %i[show update destroy]
      before_action :authorize_admin, only: %i[create update destroy]

      # GET /api/v1/profile
      def profile
        render json: UserSerializer.new(current_user).serializable_hash.merge(
          organization: {
            id: @organization.id,
            name: @organization.name,
            subdomain: @organization.subdomain,
            email: @organization.email,
            phone_number: @organization.phone_number,
            address: @organization.address,
            web_address: @organization.web_address
          }
        ), status: :ok
      end

      # GET /organizations/:organization_id/users or /api/v1/users (with subdomain)
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

        @users = @users.paginate(page: params[:page], per_page: 10)

        render json: {
          users: UserSerializer.new(@users).serializable_hash,
          pagination: {
            current_page: @users.current_page,
            total_pages: @users.total_pages,
            total_entries: @users.total_entries
          }
        }
      end

      # GET /users/:id
      def show
        render json: UserSerializer.new(@user).serializable_hash
      end

      # POST /organizations/:organization_id/users
      def create
        @user = @organization.users.new(user_params)

        if @user.save
          render json: UserSerializer.new(@user).serializable_hash, status: :created, location: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /users/:id
      def update
        if @user.update(user_params)
          render json: UserSerializer.new(@user).serializable_hash
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /users/:id
      def destroy
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

      # Override current_user to use token-based authentication from ApplicationController
      # Remove this if already defined correctly in ApplicationController
      # def current_user
      #   @current_user ||= User.find_by(id: session[:user_id]) # This is session-based, replace if using token
      # end
    end
  end
end
