# frozen_string_literal: true
module Api
  module V1
      class NotificationsController < ApplicationController
          before_action :authenticate_user!
          before_action :set_organization
        
          # GET /organizations/:organization_id/notifications
          def index
            @notifications = current_user.notifications
                                        .where(organization: @organization, read: false)
            render json: @notifications, status: :ok
          end
        
          # PATCH /organizations/:organization_id/notifications/:id/mark_as_read
          def mark_as_read
            @notification = current_user.notifications
                                        .find_by(id: params[:id], organization: @organization)
            unless @notification
              return render json: { error: "Notification not found" }, status: :not_found
            end
        
            @notification.update!(read: true)
            head :no_content
          end
        
          private
        
          def set_organization
            @organization = Organization.find(params[:organization_id])
          rescue ActiveRecord::RecordNotFound
            render json: { error: 'Organization not found' }, status: :not_found
          end
      end
  end
end