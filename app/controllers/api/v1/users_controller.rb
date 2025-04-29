module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_organization_from_subdomain
      before_action :authenticate_user!, except: []
      before_action :set_user, only: %i[show update destroy]
      before_action :authorize_admin, only: %i[create update destroy]

      def profile
        return render_unauthorized unless current_user

        user = @organization.users.find_by(id: current_user.id)
        return render_not_found('User') unless user

        render_profile(user)
      end

      def index
        @users = @organization.users
        apply_filters
        render_users
      end

      def show
        authorize @user
        render_user
      rescue ActiveRecord::RecordNotFound
        render_not_found('User')
      rescue StandardError => e
        render_server_error(e)
      end

      def create
        begin
          # Log the parameters being received
          Rails.logger.info "Creating user with params: #{user_params.inspect}"
          
          # Create user with auth token
          @user = @organization.users.new(user_params)
          @user.auth_token = SecureRandom.hex(20)
          
          # Set skip_auth_token to true to avoid regenerating it
          @user.skip_auth_token = true if @user.respond_to?(:skip_auth_token=)
          
          if @user.save
            Rails.logger.info "User created successfully: #{@user.id}"
            render json: user_attributes(@user), status: :created
          else
            # Log validation errors
            Rails.logger.error "User validation failed: #{@user.errors.full_messages.inspect}"
            log_and_render_validation_error
          end
        rescue StandardError => e
          # Log any exceptions
          Rails.logger.error "Exception in user creation: #{e.class.name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render_server_error(e)
        end
      end

      def update
        begin
          if @user.update(user_params)
            render json: user_attributes(@user), status: :ok
          else
            log_and_render_validation_error
          end
        rescue StandardError => e
          render_server_error(e)
        end
      end

      def destroy
        begin
          @user.destroy!
          head :no_content
        rescue ActiveRecord::RecordNotFound
          render_not_found('User')
        rescue StandardError => e
          render_server_error(e)
        end
      end

      private

      def set_organization_from_subdomain
        subdomain = params[:subdomain] || params[:organization_subdomain] || request.subdomains.first
        
        # Ensure subdomain is not nil before downcasing
        if subdomain.nil?
          Rails.logger.error "No subdomain found in request"
          return render_not_found('Organization')
        end
        
        @organization = Organization.find_by("LOWER(subdomain) = ?", subdomain.downcase)
        return if @organization

        render_not_found('Organization')
      end

      def set_user
        @user = @organization.users.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_not_found('User')
      end

      def user_params
        params.require(:user).permit(
          :name, :email, :username, :phone_number,
          :department, :position, :role, :password,
          :password_confirmation
        )
      end

      def authorize_admin
        return if current_user&.admin?

        render_forbidden
      end

      def apply_filters
        @users = @users.filter_by_role(params[:role]) if params[:role].present?
        @users = @users.filter_by_department(params[:department]) if params[:department].present?
        @users = @users.filter_by_position(params[:position]) if params[:position].present?
        @users = @users.filter_by_team(params[:team_id]) if params[:team_id].present?
      end

      def render_users
        if @users.empty?
          render_empty_users
        else
          render json: @users.map { |user| user_attributes(user) }, status: :ok
        end
      end

      def render_empty_users
        Rails.logger.info "No users found for organization: #{@organization.subdomain}"
        render json: { message: "No users found", users: [] }, status: :ok
      end

      def render_profile(user)
        render json: {
          user: user_profile_attributes(user),
          organization: organization_attributes
        }, status: :ok
      end

      def user_profile_attributes(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          is_admin: user.admin?,
          name: user.name,
          username: user.username,
          department: user.department,
          position: user.position
        }
      end

      def organization_attributes
        {
          id: @organization.id,
          name: @organization.name,
          subdomain: @organization.subdomain,
          email: @organization.email,
          web_address: @organization.web_address
        }
      end

      def render_user
        render json: user_attributes(@user), status: :ok
      end

      def user_attributes(user)
        {
          id: user.id,
          name: user.name,
          username: user.username,
          email: user.email,
          role: user.role,
          team_id: user.team_id,
          department: user.department,
          position: user.position
        }
      end

      def log_and_render_validation_error
        error_messages = @user.errors.full_messages
        Rails.logger.error "User validation failed: #{error_messages.join(', ')}"
        
        # Return a standardized error format with just a single error key
        render json: { error: error_messages.join(', ') }, status: :unprocessable_entity
      end

      def render_server_error(exception)
        Rails.logger.error "Server error in UsersController: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        
        # Return a standardized error format with just a single error key
        render json: { error: "Server error: #{exception.message}" }, status: :unprocessable_entity
      end

      def render_unauthorized
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def render_not_found(entity)
        render json: { error: "#{entity} not found" }, status: :not_found
      end

      def render_forbidden
        render json: { error: 'Forbidden' }, status: :forbidden
      end
    end
  end
end
