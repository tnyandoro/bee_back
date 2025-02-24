# frozen_string_literal: true
module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!, only: [:profile, :index, :show, :create, :update, :destroy]
      before_action :set_organization_from_subdomain # Use subdomain for all actions
      before_action :verify_user_organization, only: [:profile, :index, :show, :create, :update, :destroy]
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

      # GET /api/v1/organizations/:subdomain/users
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

      # GET /api/v1/organizations/:subdomain/users/:id
      def show
        render json: UserSerializer.new(@user).serializable_hash
      end

      # POST /api/v1/organizations/:subdomain/users
      def create
        @user = @organization.users.new(user_params)
        @user.auth_token = SecureRandom.hex(20) # Generate token for new user

        if @user.save
          render json: UserSerializer.new(@user).serializable_hash, status: :created, 
                 location: api_v1_organization_user_url(@organization.subdomain, @user)
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/organizations/:subdomain/users/:id
      def update
        if @user.update(user_params)
          render json: UserSerializer.new(@user).serializable_hash
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/organizations/:subdomain/users/:id
      def destroy
        @user.destroy!
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions
      def set_user
        @user = @organization.users.find_by!(id: params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through
      def user_params
        params.require(:user).permit(
          :name, :email, :username, :phone_number, :department, :position, :role, :password
        )
      end

      # Ensure only admins or super users can perform certain actions
      def authorize_admin
        unless current_user&.role_admin? || current_user&.role_super_user?
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end
    end
  end
end
