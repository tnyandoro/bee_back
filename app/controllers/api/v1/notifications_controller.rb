# app/controllers/api/v1/notifications_controller.rb
module Api
  module V1
    class NotificationsController < Api::V1::ApiController

      # GET /organizations/:organization_id/notifications
      def index
        @notifications = current_user.notifications
                                   .where(organization: @organization, read: false)
                                   .includes(:notifiable)
                                   .order(created_at: :desc)
        
        render json: @notifications.as_json(
          include: {
            notifiable: {
              only: [:id, :title, :ticket_number],
              methods: [:notification_type]
            }
          }
        ), status: :ok
      end

      # PATCH /organizations/:organization_id/notifications/:id/mark_as_read
      def mark_as_read
        @notification = current_user.notifications
                                  .find_by(id: params[:id], organization: @organization)
        
        unless @notification
          render_error(message: ErrorCodes::Messages.NOTIFICATION_NOT_FOUND, error_code: ErrorCodes::Codes.NOTIFICATION_NOT_FOUND, status: :not_found)
          return
        end

        @notification.update!(read: true)
        render json: @notification.as_json(include: :notifiable), status: :ok
      end

      private

      def set_organization
        @organization = Organization.find(params[:organization_id])
      rescue ActiveRecord::RecordNotFound
        render_error(message: ErrorCodes::Messages.ORGANIZATION_NOT_FOUND, error_code: ErrorCodes::Codes.ORGANIZATION_NOT_FOUND, status: :not_found)
      end
    end
  end
end