module Api
    module V1
      class OrganizationsController < ApplicationController
        def index
          organizations = Organization.all
          render json: organizations
        end
  
        def show
          organization = Organization.find(params[:id])
          render json: organization
        end
  
        # Add create, update, and destroy as needed
      end
    end
end
