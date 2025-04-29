module Api
  module V1
    module Organizations
      class ProfilesController < ApplicationController
        before_action :set_organization

        def show
          if @organization
            render json: {
              name: @organization.name,
              slug: @organization.slug,
              logo_url: url_for(@organization.logo) rescue nil,
              created_at: @organization.created_at,
              admins: @organization.admins.select(:id, :name, :email)
            }, status: :ok
          else
            render json: { error: 'Organization not found' }, status: :not_found
          end
        end

        private

        def set_organization
          @organization = Organization.find_by(slug: params[:slug])
        end
      end
    end
  end
end
