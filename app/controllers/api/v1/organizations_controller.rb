# app/controllers/api/v1/organizations_controller.rb
module Api
  module V1
    class OrganizationsController < ApplicationController
      before_action :set_organization, only: %i[show update destroy users add_user]

      # GET /api/v1/organizations
      def index
        @organizations = Organization.all
        render json: @organizations
      end

      # GET /api/v1/organizations/:subdomain
      def show
        render json: @organization
      end

      # POST /api/v1/organizations
      def create
        ActiveRecord::Base.transaction do
          @organization = Organization.new(organization_params)
          if @organization.save
            @admin = @organization.users.new(admin_params.merge(role: 'admin'))
            if @admin.save
              # Send notification to the admin
              NotificationService.notify_user(
                @admin,
                @organization,
                "Welcome! You have been added as an admin to the organization: #{@organization.name}"
              )
              render json: { organization: @organization, admin: @admin }, status: :created
            else
              raise ActiveRecord::Rollback
            end
          else
            render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # PATCH/PUT /api/v1/organizations/:subdomain
      def update
        if @organization.update(organization_params)
          render json: @organization
        else
          render json: { errors: @organization.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/organizations/:subdomain
      def destroy
        if @organization.destroy
          head :no_content
        else
          render json: { error: "Failed to delete organization" }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/organizations/:subdomain/users
      def users
        @users = @organization.users
        render json: @users
      end

      # POST /api/v1/organizations/:subdomain/users
      def add_user
        @user = User.find_by(id: params[:user_id]) # Assuming user_id is passed
        unless @user
          return render json: { error: "User not found" }, status: :not_found
        end

        # Add user to organization (assuming a join table or direct association)
        unless @organization.users.include?(@user)
          @organization.users << @user
          # Send notification to the user
          NotificationService.notify_user(
            @user,
            @organization,
            "You have been added to the organization: #{@organization.name}"
          )
          render json: { message: "User added successfully", user: @user }, status: :created
        else
          render json: { message: "User is already a member of this organization" }, status: :ok
        end
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_organization
        @organization = Organization.find_by!(subdomain: params[:subdomain])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Organization not found' }, status: :not_found
      end

      def organization_params
        params.require(:organization).permit(:name, :address, :email, :web_address, :subdomain)
      end

      def admin_params
        params.require(:admin).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end