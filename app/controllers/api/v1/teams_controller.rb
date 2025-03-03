# frozen_string_literal: true
module Api
  module V1
    class TeamsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain
      before_action :authorize_admin_or_super_user, except: [:index, :show, :users]
      before_action :set_team, only: [:show, :update, :destroy, :users]

      # GET /api/v1/organizations/:subdomain/teams
      def index
        @teams = @organization.teams
        render json: @teams.map { |team| { id: team.id, name: team.name } }
      end

      # GET /api/v1/organizations/:subdomain/teams/:id
      def show
        render json: team_attributes(@team)
      end

      # GET /api/v1/organizations/:subdomain/teams/:team_id/users
      def users
        @users = @team.users
        render json: @users.map { |user| { id: user.id, name: user.name || user.username, team_id: user.team_id } }
      end

      # POST /api/v1/organizations/:subdomain/teams
      def create
        @team = @organization.teams.new(team_params.except(:user_ids))

        if team_params[:user_ids].present?
          users = @organization.users.where(id: team_params[:user_ids])
          if users.count != team_params[:user_ids].size
            render json: { error: 'One or more users not found in this organization' }, status: :unprocessable_entity
            return
          end
          @team.users = users
        end

        if @team.save
          render json: team_attributes(@team), status: :created, 
                 location: api_v1_organization_team_url(@organization.subdomain, @team)
        else
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/organizations/:subdomain/teams/:id
      def update
        if team_params[:user_ids].present?
          users = @organization.users.where(id: team_params[:user_ids])
          if users.count != team_params[:user_ids].size
            render json: { error: 'One or more users not found in this organization' }, status: :unprocessable_entity
            return
          end
          @team.users = users
        end

        if @team.update(team_params.except(:user_ids))
          render json: team_attributes(@team)
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

      def set_organization_from_subdomain
        subdomain = request.subdomain.presence || 'default'
        @organization = Organization.find_by!(subdomain: subdomain)
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Organization not found for this subdomain' }, status: :not_found
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
          name: user.name,
          email: user.email,
          role: user.role
        }
      end
    end
  end
end