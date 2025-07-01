module Api
  module V1
    class DashboardController < ApplicationController
      before_action :set_organization

      def show
        render json: {
          organization: {
            name: @organization.name,
            address: @organization.address,
            email: @organization.email,
            website: @organization.website,
          },
          stats: {
            total_tickets: @organization.tickets.count,
            open_tickets: @organization.tickets.where(status: 'open').count,
            closed_tickets: @organization.tickets.where(status: 'closed').count,
            total_problems: @organization.problems.count,
            total_members: @organization.users.count
          }
        }
      end

      private

      def set_organization
        @organization = Organization.find_by!(subdomain: params[:subdomain])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Organization not found" }, status: :not_found
      end
    end
  end
end
