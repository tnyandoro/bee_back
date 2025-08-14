module Api
  module V1
    class KnowledgebaseController < ApplicationController
      before_action :authenticate_user
      before_action :set_organization

      def index
        knowledge_entries = @organization.knowledgebase_entries || []
        render json: knowledge_entries, status: :ok
      end

      private

      def set_organization
        @organization = Organization.find_by(subdomain: params[:subdomain])
        unless @organization
          render json: { error: 'Organization not found' }, status: :not_found
        end
      end

      def authenticate_user
        token = request.headers['Authorization']&.split(' ')&.last
        unless token && valid_token?(token)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end

      def valid_token?(token)
        # Replace with actual JWT validation
        true
      end
    end
  end
end
