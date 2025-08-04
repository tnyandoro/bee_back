module Api
  module V1
    class UsersController < ApplicationController
      include Pundit::Authorization

      before_action :set_organization_from_subdomain
      before_action :authenticate_user!
      before_action :set_user, only: [:show, :update, :destroy, :profile]
      after_action :verify_authorized

      def profile
        authorize @user
        render json: user_profile_attributes(@user)
      rescue ActiveRecord::RecordNotFound
        render_not_found('User')
      rescue StandardError => e
        render_server_error(e)
      end

      def index
        @users = policy_scope(User)
        apply_filters
        render_users
      rescue StandardError => e
        render_server_error(e)
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
        Rails.logger.info "Creating user with params: #{user_params.inspect}"
        @user = @organization.users.new(user_params)
        @user.auth_token = SecureRandom.hex(20)
        @user.skip_auth_token = true if @user.respond_to?(:skip_auth_token=)
        authorize @user

        if @user.save
          Rails.logger.info "User created successfully: #{@user.id}"
          render json: user_attributes(@user), status: :created
        else
          log_and_render_validation_error
        end
      rescue StandardError => e
        Rails.logger.error "Exception in user creation: #{e.class.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render_server_error(e)
      end

      def roles
        render json: User.roles.map { |key, _| { value: key, label: key.humanize } }
      end

      def update
        authorize @user
        if @user.update(user_params)
          render json: user_attributes(@user), status: :ok
        else
          log_and_render_validation_error
        end
      rescue StandardError => e
        render_server_error(e)
      end

      def destroy
        authorize @user
        @user.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render_not_found('User')
      rescue StandardError => e
        render_server_error(e)
      end

      private

      def set_organization_from_subdomain
        subdomain = params[:subdomain] || params[:organization_subdomain] || request.subdomains.first
        Rails.logger.debug "Attempting to find organization with subdomain: #{subdomain.inspect}"

        unless subdomain
          Rails.logger.error "No subdomain provided in request. Params: #{params.inspect}, Host: #{request.host}"
          render json: { error: "Subdomain is required" }, status: :not_found
          return
        end

        @organization = Organization.find_by("LOWER(subdomain) = ?", subdomain.downcase)
        unless @organization
          Rails.logger.error "Organization not found for subdomain: #{subdomain}"
          render json: { error: "Organization not found" }, status: :not_found
        end
      end

      def set_user
        @user = @organization.users.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_not_found('User')
      end

      def user_params
        params.require(:user).permit(
          :name,
          :last_name,
          :email,
          :username,
          :phone_number,
          :position,
          :role,
          :password,
          :password_confirmation,
          :avatar,
          :department_id
        )
      end

      def apply_filters
        @users = @users.filter_by_role(params[:role]) if params[:role].present?
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
          department_id: user.department_id,
          position: user.position,
          avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil
        }
      end

      def user_profile_attributes(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          is_admin: user.role.in?(['system_admin', 'domain_admin']),
          name: user.name,
          username: user.username,
          position: user.position,
          avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil
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

      def log_and_render_validation_error
        error_messages = @user.errors.full_messages
        Rails.logger.error "User validation failed: #{error_messages.join(', ')}"
        render json: { error: error_messages.join(', ') }, status: :unprocessable_entity
      end

      def render_server_error(exception)
        Rails.logger.error "Server error in UsersController: #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n")
        render json: { error: "Server error: #{exception.message}" }, status: :unprocessable_entity
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