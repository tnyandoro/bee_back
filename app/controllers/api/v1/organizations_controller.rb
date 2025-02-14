# app/controllers/api/v1/organizations_controller.rb
module Api
  module V1
    class OrganizationsController < ApplicationController
      before_action :set_organization, only: %i[show update destroy users]

      # GET /api/v1/organizations
      def index
        @organizations = Organization.all
        render json: @organizations
      end

      # GET /api/v1/organizations/1
      def show
        render json: @organization
      end

      # POST /api/v1/organizations
      def create
        @organization = Organization.new(organization_params)

        if @organization.save
          render json: @organization, status: :created, location: api_v1_organization_url(@organization)
        else
          render json: @organization.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/organizations/1
      def update
        if @organization.update(organization_params)
          render json: @organization
        else
          render json: @organization.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/organizations/1
      def destroy
        @organization.destroy!
        head :no_content
      end

      # GET /api/v1/organizations/:id/users
      def users
        @users = @organization.users
        render json: @users
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_organization
        @organization = Organization.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Organization not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def organization_params
        params.require(:organization).permit(:name, :address, :email, :web_address, :subdomain)
      end
    end
  end
end
