module Api
  module V1
    class OrganizationsController < ApplicationController
      before_action :set_organization, only: %i[show update destroy users]

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
              render json: { organization: @organization, admin: @admin }, status: :created
            else
              raise ActiveRecord::Rollback
            end
          else
            render json: @organization.errors, status: :unprocessable_entity
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
          render json: @organization.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/organizations/:subdomain
      def destroy
        @organization.destroy!
        head :no_content
      end

      # GET /api/v1/organizations/:subdomain/users
      def users
        @users = @organization.users
        render json: @users
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
