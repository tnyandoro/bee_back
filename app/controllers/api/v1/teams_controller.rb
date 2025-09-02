# frozen_string_literal: true

module Api
  module V1
    class TeamsController < Api::V1::ApiController
      before_action :authorize_admin_or_super_user, except: [:index, :show, :users]
      before_action :set_team, only: [:show, :update, :deactivate, :users]

      # GET /api/v1/organizations/:organization_subdomain/teams
      def index
        @teams = @organization.teams.includes(:users).where(deactivated_at: nil) # Filter active teams
        render json: @teams.map { |team| team_attributes(team) }, status: :ok
      end

      # GET /api/v1/organizations/:organization_subdomain/teams/:id
      def show
        render json: team_attributes(@team), status: :ok
      end

      # GET /api/v1/organizations/:organization_subdomain/teams/:team_id/users
      def users
        @users = @team.users.includes(:team)
        render json: @users.map { |user| user_attributes(user) }, status: :ok
      end

      # POST /api/v1/organizations/:organization_subdomain/teams
      def create
        Rails.logger.info("Create Team Params: #{params.inspect}")
        Rails.logger.info("Organization: #{@organization.inspect}")
      
        @team = @organization.teams.new(team_params.except(:user_ids))
      
        ActiveRecord::Base.transaction do
          if @team.save
            if team_params[:user_ids].present?
              assign_users_to_team(@team, team_params[:user_ids])
            end
            render json: team_attributes(@team), status: :created,
                   location: api_v1_organization_team_url(@organization.subdomain, @team)
          else
            Rails.logger.error("Team save errors: #{@team.errors.full_messages.join(', ')}")
            render_error(errors: @team.errors.full_messages, message: ErrorCodes::Messages::FAILED_TO_CREATE_TEAM, error_code: ErrorCodes::Codes::FAILED_TO_CREATE_TEAM, status: :unprocessable_entity)
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("ActiveRecord::RecordInvalid: #{e.record.errors.full_messages.join(', ')}")
        render_error(errors: e.record.errors.full_messages, message: ErrorCodes::Messages::FAILED_TO_CREATE_TEAM, error_code: ErrorCodes::Codes::FAILED_TO_CREATE_TEAM, status: :unprocessable_entity)
      rescue StandardError => e
        Rails.logger.error("TeamsController#create StandardError: #{e.class} - #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        render_error(message: ErrorCodes::Messages::INTERNAL_SERVER_ERROR, error_code: ErrorCodes::Codes::INTERNAL_SERVER_ERROR, status: :internal_server_error)
      end

      # PATCH/PUT /api/v1/organizations/:organization_subdomain/teams/:id
      def update
        ActiveRecord::Base.transaction do
          if team_params[:user_ids].present?
            assign_users_to_team(@team, team_params[:user_ids])
          end

          if @team.update(team_params.except(:user_ids))
            render json: team_attributes(@team), status: :ok
          else
            render_error(errors: @team.errors.full_messages, message: ErrorCodes::Messages::FAILED_TO_UPDATE_TEAM, error_code: ErrorCodes::Codes::FAILED_TO_UPDATE_TEAM, status: :unprocessable_entity)
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render_error(errors: e.record.errors.full_messages, message: ErrorCodes::Messages::FAILED_TO_UPDATE_TEAM, error_code: ErrorCodes::Codes::FAILED_TO_UPDATE_TEAM, status: :unprocessable_entity)
      end

      # PATCH /api/v1/organizations/:organization_subdomain/teams/:id/deactivate
      def deactivate
        ActiveRecord::Base.transaction do
          @team.update!(deactivated_at: Time.current)
          User.where(team_id: @team.id).update_all(team_id: nil) # Unassign users
          @organization.tickets.where(team_id: @team.id).update_all(team_id: nil) # Unassign tickets
        end
        render json: { message: "Team deactivated successfully" }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render_error(errors: e.record.errors.full_messages, message: ErrorCodes::Messages::FAILED_TO_DELETE_TEAM, error_code: ErrorCodes::Codes::FAILED_TO_DELETE_TEAM, status: :unprocessable_entity)
      end

      private

      def set_team
        @team = @organization.teams.where(deactivated_at: nil).find(params[:id] || params[:team_id])
      rescue ActiveRecord::RecordNotFound
        render_error(message: ErrorCodes::Messages::TEAM_NOT_FOUND, error_code: ErrorCodes::Codes::TEAM_NOT_FOUND, status: :not_found)
      end

      def team_params
        params.require(:team).permit(:name, user_ids: [])
      end

      def authorize_admin_or_super_user
        unless current_user&.is_admin? || current_user&.super_user?
          render_error(message: ErrorCodes::Messages::UNAUTHORIZED_TO_MANAGE_TEAMS, error_code: ErrorCodes::Codes::UNAUTHORIZED_TO_MANAGE_TEAMS, status: :forbidden)
        end
      end

      def assign_users_to_team(team, user_ids)
        user_ids = user_ids.map(&:to_i).uniq
        current_user_ids = team.users.pluck(:id)
        to_remove = current_user_ids - user_ids
        
        if to_remove.present?
          User.where(id: to_remove).update_all(team_id: nil)
        end
        
        if user_ids.present?
          users = @organization.users.where(id: user_ids)
          if users.count != user_ids.size
            missing_ids = user_ids - users.pluck(:id)
            raise ActiveRecord::RecordInvalid.new(
              Team.new.tap { |t| t.errors.add(:user_ids, "Users not found: #{missing_ids.join(', ')}") }
            )
          end
          User.where(id: user_ids).update_all(team_id: team.id)
        end
      end

      def team_attributes(team)
        {
          id: team.id,
          name: team.name,
          organization_id: team.organization_id,
          user_ids: team.users.pluck(:id),
          user_count: team.users.count,
          created_at: team.created_at&.in_time_zone('Pretoria')&.iso8601,
          updated_at: team.updated_at&.in_time_zone('Pretoria')&.iso8601,
          deactivated_at: team.deactivated_at&.in_time_zone('Pretoria')&.iso8601
        }
      end

      def user_attributes(user)
        {
          id: user.id,
          name: user.name || user.username,
          email: user.email,
          role: user.role,
          team_id: user.team_id,
          team_name: user.team&.name
        }
      end
    end
  end
end