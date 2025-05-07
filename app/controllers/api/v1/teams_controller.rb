# frozen_string_literal: true

module Api
  module V1
    class TeamsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain
      before_action :authorize_admin_or_super_user, except: [:index, :show, :users]
      before_action :set_team, only: [:show, :update, :destroy, :users]

      # GET /api/v1/organizations/:organization_subdomain/teams
      def index
        @teams = @organization.teams.includes(:users) # Eager loading users
        render json: @teams.map { |team| team_attributes(team) }, status: :ok
      end

      # GET /api/v1/organizations/:organization_subdomain/teams/:id
      def show
        render json: team_attributes(@team), status: :ok
      end

      # GET /api/v1/organizations/:organization_subdomain/teams/:team_id/users
      def users
        @users = @team.users.includes(:team) # Eager loading team
        render json: @users.map { |user| user_attributes(user) }, status: :ok
      end

      # POST /api/v1/organizations/:organization_subdomain/teams
      def create
        @team = @organization.teams.new(team_params.except(:user_ids))
        
        ActiveRecord::Base.transaction do
          if @team.save
            if team_params[:user_ids].present?
              assign_users_to_team(@team, team_params[:user_ids]) 
            end
            render json: team_attributes(@team), status: :created,
                   location: api_v1_organization_team_url(@organization.subdomain, @team)
          else
            render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
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
            render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # DELETE /api/v1/organizations/:organization_subdomain/teams/:id
      def destroy
        if @team.destroy
          head :no_content
        else
          render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_organization_from_subdomain
        @organization = Organization.find_by(subdomain: params[:organization_subdomain])
        unless @organization
          render json: { error: 'Organization not found' }, status: :not_found
          return
        end
      end

      def set_team
        @team = @organization.teams.find(params[:id] || params[:team_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Team not found in this organization' }, status: :not_found
      end

      def team_params
        params.require(:team).permit(:name, user_ids: [])
      end

      def authorize_admin_or_super_user
        unless current_user&.admin? || current_user&.super_user?
          render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
        end
      end

      def assign_users_to_team(team, user_ids)
        # Convert to integers and remove duplicates
        user_ids = user_ids.map(&:to_i).uniq
        
        # Find users that belong to this organization
        users = @organization.users.where(id: user_ids)
        
        # Verify all requested users were found
        if users.count != user_ids.size
          missing_ids = user_ids - users.pluck(:id)
          raise ActiveRecord::RecordInvalid.new(
            Team.new.tap { |t| t.errors.add(:user_ids, "Users not found: #{missing_ids.join(', ')}") }
          )
        end

        # Update all users in a single query
        User.where(id: user_ids).update_all(team_id: team.id)
      end

      def team_attributes(team)
        {
          id: team.id,
          name: team.name,
          organization_id: team.organization_id,
          user_ids: team.user_ids,
          user_count: team.users.count,
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
          team_id: user.team_id,
          team_name: user.team&.name
        }
      end
    end
  end
end
