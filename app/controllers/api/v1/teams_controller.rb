# app/controllers/api/v1/teams_controller.rb
# frozen_string_literal: true
module Api
  module V1
    class TeamsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain
      before_action :authorize_admin_or_super_user, except: [:index, :show]
      before_action :set_team, only: [:show, :update, :destroy]

      # GET /api/v1/organizations/:subdomain/teams
      def index
        @teams = @organization.teams
        @teams = @teams.paginate(page: params[:page], per_page: 10)
        if @teams.empty?
          render json: { message: "No teams found in this organization" }, status: :ok
        else
          render json: {
            teams: @teams.map { |team| team_attributes(team) },
            pagination: {
              current_page: @teams.current_page,
              total_pages: @teams.total_pages,
              total_entries: @teams.total_entries
            }
          }
        end
      end

      # GET /api/v1/organizations/:subdomain/teams/:id
      def show
        render json: team_attributes(@team)
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
        @team = @organization.teams.find(params[:id])
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
    end
  end
end