# frozen_string_literal: true
module Api
  module V1
    class TeamsController < ApplicationController
      before_action :authenticate_user!
      # before_action :set_organization_from_subdomain
      before_action :authorize_admin_or_super_user, except: [:index, :show, :users]
      before_action :set_team, only: [:show, :update, :destroy, :users]

      # GET /api/v1/organizations/:subdomain/teams
      def index
        @teams = @organization.teams
        render json: @teams.map { |team| team_attributes(team) }, status: :ok
      end

      # GET /api/v1/organizations/:subdomain/teams/:id
      def show
        render json: team_attributes(@team), status: :ok
      end

      # GET /api/v1/organizations/:subdomain/teams/:team_id/users
      def users
        @users = @team.users
        render json: @users.map { |user| user_attributes(user) }, status: :ok
      end

      # POST /api/v1/organizations/:subdomain/teams
      def create
        @team = @organization.teams.new(team_params.except(:user_ids))
        Rails.logger.info "🔥 Creating team: #{@team.inspect}"

        if @team.save
          assign_users_to_team(@team, team_params[:user_ids]) if team_params[:user_ids].present?
          render json: team_attributes(@team), status: :created,
                 location: api_v1_organization_team_url(@organization.subdomain, @team)
        else
          Rails.logger.error "❌ Team creation failed: #{@team.errors.full_messages.join(", ")}"
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/organizations/:subdomain/teams/:id
      def update
        if team_params[:user_ids].present?
          assign_users_to_team(@team, team_params[:user_ids])
        end

        if @team.update(team_params.except(:user_ids))
          render json: team_attributes(@team), status: :ok
        else
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/organizations/:subdomain/teams/:id
      def destroy
        @team.destroy!
        head :no_content
      end

      private

      def set_team
        @team = @organization.teams.find(params[:id] || params[:team_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Team not found in this organization' }, status: :not_found
      end

      def team_params
        params.require(:team).permit(:name, user_ids: [])
      end

      def authorize_admin_or_super_user
        unless current_user&.role_admin? || current_user&.role_super_user?
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end

      def assign_users_to_team(team, user_ids)
        users = @organization.users.where(id: user_ids)
        if users.count != user_ids.size
          Rails.logger.warn "⚠️ Invalid user IDs: Expected #{user_ids.size}, found #{users.count}"
          render json: { error: 'One or more users not found in this organization' }, status: :unprocessable_entity
          return
        end

        # Clear current assignments for those users to avoid conflicts
        User.where(id: user_ids).update_all(team_id: team.id)
        Rails.logger.info "✅ Assigned users to team #{team.id}: #{user_ids}"
      end

      def team_attributes(team)
        {
          id: team.id,
          name: team.name,
          organization_id: team.organization_id,
          user_ids: team.users.pluck(:id),
          created_at: team.created_at.iso8601,
          updated_at: team.updated_at.iso8601
        }
      end

      def user_attributes(user)
        {
          id: user.id,
          name: user.name || user.username,
          email: user.email,
          role: user.role,
          team_id: user.team_id
        }
      end
    end
  end
end
