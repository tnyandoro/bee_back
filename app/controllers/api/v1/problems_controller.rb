# frozen_string_literal: true
module Api
  module V1
    class ProblemsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_organization_from_subdomain
      before_action :set_problem, only: %i[show update destroy]

      def index
        if params[:organization_id]
          @organization = Organization.find(params[:organization_id])
          @problems = Problem.joins(:ticket).where(tickets: { organization_id: @organization.id })
        elsif params[:user_id]
          @user = User.find(params[:user_id])
          @problems = @user.problems
        else
          @problems = @organization.problems
        end
        render json: @problems
      end

      def show
        render json: @problem
      end

      def create
        Rails.logger.debug "Problem params: #{params.inspect}" # Debug incoming params

        @ticket = @organization.tickets.find_by(id: params[:problem][:ticket_id]) if params[:problem][:ticket_id].present?
        @problem = Problem.new(problem_params.merge(creator: current_user, organization: @organization))

        if @ticket
          @problem.ticket = @ticket
          @ticket.update(status: 'escalated') # Update ticket status if escalated
        end

        if @problem.save
          render json: @problem, status: :created, location: api_v1_organization_problem_url(@organization.subdomain, @problem)
        else
          Rails.logger.debug "Problem errors: #{@problem.errors.full_messages}" # Debug validation errors
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error "Error creating problem: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: 'Internal server error', details: e.message }, status: :internal_server_error
      end

      def update
        if @problem.update(problem_params)
          render json: @problem
        else
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @problem.destroy!
        head :no_content
      end

      private

      def set_problem
        @problem = @organization.problems.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Problem not found in this organization' }, status: :not_found
      end

      def problem_params
        params.require(:problem).permit(:description, :ticket_id, :team_id, :user_id)
      end

      def set_organization_from_subdomain
        subdomain = request.subdomain.presence || 'default'
        @organization = Organization.find_by!(subdomain: subdomain)
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Organization not found for this subdomain' }, status: :not_found
      end
    end
  end
end
