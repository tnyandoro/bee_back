# frozen_string_literal: true
module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!, only: [:profile, :index, :show, :create, :update, :destroy]
      before_action :set_organization_from_subdomain
      before_action :verify_user_organization, only: [:profile, :index, :show, :create, :update, :destroy]
      before_action :set_user, only: %i[show update destroy]
      before_action :authorize_admin, only: %i[create update destroy]

      # GET /api/v1/profile
      def profile
        unless current_user
          render json: { error: 'User not authenticated' }, status: :unauthorized
          return
        end

        render json: {
          user: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.name,
            username: current_user.username,
            phone_number: current_user.phone_number,
            department: current_user.department,
            position: current_user.position,
            role: current_user.role,
            auth_token: current_user.auth_token,
            team_id: current_user.team_id
          },
          organization: {
            id: @organization.id,
            name: @organization.name,
            subdomain: @organization.subdomain,
            email: @organization.email,
            phone_number: @organization.phone_number,
            address: @organization.address,
            web_address: @organization.web_address
          }
        }, status: :ok
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

        render json: @users.map { |user| user_attributes(user) }
      end

      # GET /api/v1/organizations/:subdomain/users/:id
      def show
        render json: user_attributes(@user)
      end

      # POST /api/v1/organizations/:subdomain/users
      def create
        @user = @organization.users.new(user_params)
        @user.auth_token = SecureRandom.hex(20)

        if @user.save
          render json: user_attributes(@user), status: :created, 
                 location: api_v1_organization_user_url(@organization.subdomain, @user)
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/organizations/:subdomain/users/:id
      def update
        if @user.update(user_params)
          render json: user_attributes(@user)
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

      def set_user
        @user = @organization.users.find_by!(id: params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def user_params
        params.require(:user).permit(
          :name, :email, :username, :phone_number, :department, :position, :role, :password
        )
      end

      def authorize_admin
        unless current_user&.role_admin? || current_user&.role_super_user?
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end

      def set_organization_from_subdomain
        subdomain = request.subdomain.presence || 'default'
        @organization = Organization.find_by!(subdomain: subdomain)
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Organization not found for this subdomain' }, status: :not_found
      end

      def verify_user_organization
        unless current_user&.organization_id == @organization.id
          render json: { error: 'You do not belong to this organization' }, status: :forbidden
        end
      end

      def user_attributes(user)
        {
          id: user.id,
          name: user.name,
          username: user.username,
          email: user.email,
          role: user.role,
          team_id: user.team_id
        }
      end
    end
  end
end