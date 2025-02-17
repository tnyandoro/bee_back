module Api
    module V1
      class DashboardController < ApplicationController
        before_action :set_organization
  
        # GET /api/v1/dashboard
        def show
          render json: {
            organization: {
              name: @organization.name,
              address: @organization.address,
              email: @organization.email,
              website: @organization.website,
            },
            stats: {
              total_tickets: @organization.total_tickets,
              open_tickets: @organization.open_tickets,
              closed_tickets: @organization.closed_tickets,
              total_problems: @organization.total_problems,
              total_members: @organization.total_members,
            }
          }
        end
  
        private
  
        def set_organization
          @organization = Organization.find_by!(subdomain: request.subdomain)
        end
      end
    end
end
