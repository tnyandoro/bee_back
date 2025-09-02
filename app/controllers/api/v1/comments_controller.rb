# frozen_string_literal: true
module Api
  module V1
    class CommentsController < ApiController
      before_action :set_organization_from_subdomain
      before_action :set_ticket

      def index
        render json: { comments: @ticket.comments }
      end

      def create
        comment = @ticket.comments.new(comment_params.merge(user: current_user))
        if comment.save
          render json: { comment: comment }, status: :created
        else
          render_error(errors: comment.errors.full_messages, message: ErrorCodes::Messages::FAILED_TO_CREATE_COMMENT, code: ErrorCodes::Codes::FAILED_TO_CREATE_COMMENT, status: :unprocessable_entity)
        end
      end

      private

      def set_ticket
        @ticket = @organization.tickets.find(params[:ticket_id])
      end

      def comment_params
        params.require(:comment).permit(:content)
      end
    end
  end
end
