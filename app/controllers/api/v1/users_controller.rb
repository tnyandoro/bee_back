module Api
  module V1
    class UsersController < Api::V1::ApiController
      before_action :set_user, only: [:show, :update, :destroy, :profile]
      after_action :verify_authorized

      # GET /users/profile
      def profile
        authorize @user
        render_success(user_profile_attributes(@user))
      rescue StandardError => e
        render_internal_server_error(e)
      end

      # GET /users
      def index
        @users = policy_scope(User)
        apply_filters
        render_users
      rescue StandardError => e
        render_internal_server_error(e)
      end

      # GET /users/:id
      def show
        authorize @user
        render_success(user_attributes(@user))
      rescue StandardError => e
        render_internal_server_error(e)
      end

      # POST /users
      def create
        sanitized_params = user_params.except(:password, :password_confirmation)
        Rails.logger.info "Creating user with params: #{sanitized_params.inspect}"

        @user = @organization.users.new(user_params)
        @user.auth_token = SecureRandom.hex(20)
        @user.skip_auth_token = true if @user.respond_to?(:skip_auth_token=)
        authorize @user

        if @user.save
          render_success(user_attributes(@user), "User created successfully", :created)
        else
          render_error(@user.errors.full_messages.join(', '))
        end
      rescue StandardError => e
        render_internal_server_error(e)
      end

      # GET /users/roles
      def roles
        render_success(User.roles.map { |key, _| { value: key, label: key.humanize } })
      end

      # PATCH/PUT /users/:id
      def update
        authorize @user
        if @user.update(user_params)
          render_success(user_attributes(@user))
        else
          render_error(@user.errors.full_messages.join(', '))
        end
      rescue StandardError => e
        render_internal_server_error(e)
      end

      # DELETE /users/:id
      def destroy
        authorize @user
        @user.destroy!
        head :no_content
      rescue StandardError => e
        render_internal_server_error(e)
      end

      private

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
          render_success([], "No users found")
        else
          render_success(@users.map { |user| user_attributes(user) })
        end
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
    end
  end
end
