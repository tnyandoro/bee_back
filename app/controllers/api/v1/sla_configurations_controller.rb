# app/controllers/api/v1/sla_configurations_controller.rb
module Api
    module V1
      class SlaConfigurationsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_organization_from_subdomain
        before_action :verify_admin
  
        # GET /api/v1/organizations/:subdomain/sla_configuration
        def show
          render json: {
            sla_policies: @organization.sla_policies,
            business_hours: @organization.business_hours,
            priority_matrix: @organization.priority_matrix
          }
        end
  
        # PUT /api/v1/organizations/:subdomain/sla_configuration
        def update
          ActiveRecord::Base.transaction do
            @organization.business_hours.destroy_all
            @organization.business_hours.create!(business_hours_params)
            
            @organization.sla_policies.destroy_all
            @organization.sla_policies.create!(sla_policies_params)
          end
          
          render json: { message: 'SLA configuration updated' }
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
  
        private
  
        def verify_admin
          return if current_user.admin? && current_user.organization == @organization
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
  
        def business_hours_params
          params.require(:business_hours).map do |bh|
            bh.permit(:day_of_week, :start_time, :end_time)
          end
        end
  
        def sla_policies_params
          params.require(:sla_policies).map do |policy|
            policy.permit(:priority, :response_time, :resolution_time)
          end
        end
      end
    end
end
