# module Api
#   module V1
#     class ApiController < ActionController::API
#       include Pundit::Authorization
#       include Rails.application.routes.url_helpers

#       # --- Global error handlers ---
#       rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
#       rescue_from ActionController::RoutingError, with: :render_not_found
#       rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
#       rescue_from StandardError, with: :render_internal_server_error

#       # --- Filters ---
#       before_action :verify_admin, only: %i[update destroy], if: -> { respond_to?(:update) && respond_to?(:destroy) }
#       before_action :set_organization_from_subdomain
#       before_action :authenticate_user!, except: [:create]
#       before_action :verify_user_organization, if: -> { current_user.present? && @organization.present? }, except: [:create, :validate_subdomain]

#       private

#       # ---------------------------
#       # Authentication
#       # ---------------------------
#       def authenticate_user!
#         render_error("Unauthorized", status: :unauthorized) unless current_user
#       end

#       def current_user
#         return @current_user if defined?(@current_user)

#         token = request.headers['Authorization']&.split(' ')&.last
#         return @current_user = nil if token.blank?

#         # Only debug in development; never log tokens in production
#         Rails.logger.debug { "Authenticating with token (development only)" } if Rails.env.development?

#         user = User.find_by(auth_token: token)

#         # Enforce org match if @organization is resolved
#         if @organization && user && user.organization_id != @organization.id
#           Rails.logger.warn "Token valid but user #{user.email} does not belong to org #{@organization.id}"
#           return @current_user = nil
#         end

#         @current_user = user
#       end

#       # ---------------------------
#       # Organization resolution
#       # ---------------------------
#       def set_organization_from_subdomain
#         param_subdomain = params[:subdomain] || params[:organization_subdomain] || params[:organization_id]
#         param_subdomain ||= request.subdomains.first

#         Rails.logger.info "Subdomain sources: params[:subdomain]=#{params[:subdomain]}, params[:organization_subdomain]=#{params[:organization_subdomain]}, params[:organization_id]=#{params[:organization_id]}, request.subdomains=#{request.subdomains.inspect}"

#         param_subdomain = 'demo' if Rails.env.development? && param_subdomain.blank?

#         if param_subdomain.blank? && Organization.count == 1
#           @organization = Organization.first
#           Rails.logger.info "Single-tenant fallback: Organization ID #{@organization.id}"
#           return
#         end

#         return render_error("Subdomain is missing in the request", status: :bad_request) unless param_subdomain.present?

#         @organization = Organization.find_by("LOWER(subdomain) = ?", param_subdomain.downcase)
#         return render_error("Organization not found for subdomain: #{param_subdomain}", status: :not_found) unless @organization

#         Rails.logger.info "Organization found: #{@organization.id} - #{@organization.subdomain}"
#       end

#       # ---------------------------
#       # Authorization checks
#       # ---------------------------
#       def verify_user_organization
#         return if current_user.nil? || @organization.nil?

#         if current_user.organization_id != @organization.id
#           Rails.logger.warn "User #{current_user.email} (org=#{current_user.organization_id}) tried to access org=#{@organization.id}"
#           render_error("User does not belong to this organization", status: :forbidden)
#         end
#       end

#       # ---------------------------
#       # Rendering helpers
#       # ---------------------------
#       def render_success(data, message = "Success", status = :ok)
#         render json: { message: message, data: data }, status: status
#       end

#       def render_error(errors, message: nil, details: nil, status: :unprocessable_entity)
#         render json: {
#           error: message || "An error occurred",
#           details: details || errors
#         }, status: status
#       end

#       def render_not_found(exception = nil)
#         render_error("Resource not found", details: exception&.message, status: :not_found)
#       end

#       def render_forbidden(exception = nil)
#         render_error("You are not authorized to perform this action", details: exception&.message, status: :forbidden)
#       end

#       def render_internal_server_error(exception = nil)
#         Rails.logger.error "Internal Server Error: #{exception&.message}"
#         render_error("Internal server error", details: Rails.env.production? ? nil : exception&.message, status: :internal_server_error)
#       end
#     end
#   end
# end

module Api
  module V1
    class RegistrationsController < Api::V1::ApiController
      # Skip the subdomain filter and authentication for registration
      skip_before_action :set_organization_from_subdomain, only: [:create]
      skip_before_action :authenticate_user!, only: [:create]

      # Handle validation errors
      rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

      def create
        ActiveRecord::Base.transaction do
          # Validate subdomain first
          validate_subdomain_availability!

          organization = Organization.new(organization_params)
          organization.save!

          admin = organization.users.new(admin_params.except(:department, :department_id))
          admin.role = :domain_admin
          admin.auth_token = generate_auth_token
          admin.save!

          render_success_response(organization, admin)
        end
      rescue StandardError => e
        handle_registration_error(e)
      end

      private

      # ---------------------------
      # Subdomain validation
      # ---------------------------
      def validate_subdomain_availability!
        subdomain = params[:organization][:subdomain]&.downcase
        if Organization.exists?(subdomain: subdomain)
          raise ActiveRecord::RecordInvalid.new(
            Organization.new.tap { |o| o.errors.add(:subdomain, 'has already been taken') }
          )
        end
      end

      # ---------------------------
      # Auth token generation
      # ---------------------------
      def generate_auth_token
        loop do
          token = SecureRandom.hex(20)
          break token unless User.exists?(auth_token: token)
        end
      end

      # ---------------------------
      # Strong parameters
      # ---------------------------
      def organization_params
        params.require(:organization).permit(
          :name, :email, :phone_number, :address, :subdomain, :website
        ).tap do |p|
          p[:web_address] = p.delete(:website) if p[:website]
          p[:subdomain] = p[:subdomain].downcase
        end
      end

      def admin_params
        params.require(:admin).permit(
          :name, :email, :password, :password_confirmation,
          :department_id, :position, :username
        ).tap do |p|
          p[:email] = p[:email]&.downcase
          p[:username] = p[:username]&.downcase
        end
      end

      # ---------------------------
      # Render responses
      # ---------------------------
      def render_success_response(organization, admin)
        render json: {
          message: "Registration successful",
          organization: organization.as_json(only: [:id, :name, :subdomain]),
          admin: admin.as_json(
            only: [:id, :name, :email, :username],
            methods: [:auth_token]
          )
        }, status: :created
      end

      def handle_validation_error(exception)
        render json: {
          error: "Validation failed",
          details: exception.record.errors.messages
        }, status: :unprocessable_entity
      end

      def handle_registration_error(exception)
        Rails.logger.error "Registration Error: #{exception.message}\n#{exception.backtrace.join("\n")}"

        error_message = if exception.is_a?(ActiveRecord::RecordInvalid)
                          exception.record.errors.full_messages.to_sentence
                        else
                          "Registration failed. Please try again."
                        end

        render json: {
          error: error_message
        }, status: :unprocessable_entity
      end
    end
  end
end

