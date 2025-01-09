class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :authorize_admin_or_super_user, except: [:index, :show]
  before_action :set_team, only: [:show, :update, :destroy]

  # GET /organizations/:organization_id/teams
  def index
    @teams = @organization.teams
    if @teams.empty?
      render json: { message: "No teams found in this organization" }, status: :ok
    else
      render json: @teams
    end
  end

  # GET /organizations/:organization_id/teams/:id
  def show
    render json: @team
  end

  # POST /organizations/:organization_id/teams
  def create
    @team = @organization.teams.new(team_params)
    if @team.save
      render json: @team, status: :created, location: organization_team_url(@organization, @team)
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/:organization_id/teams/:id
  def update
    if @team.update(team_params)
      render json: @team
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/:organization_id/teams/:id
  def destroy
    @team.destroy!
    head :no_content
  end

  private

  # Set the organization for all actions

  def authenticate_user!
    # Replace this with your actual authentication logic
    @current_user = User.find_by(id: session[:user_id])
    unless @current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def set_organization
    @organization = current_user.organization
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Organization not found' }, status: :not_found
  end

  # Set the team based on the team ID and organization
  def set_team
    @team = @organization.teams.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Team not found in this organization' }, status: :not_found
  end

  # Only allow a list of trusted parameters through
  def team_params
    params.require(:team).permit(:name)
  end

  # Ensure only admins and super_users can create, update, or delete teams
  def authorize_admin_or_super_user
    unless current_user.can_create_teams?
      render json: { error: 'You are not authorized to perform this action' }, status: :unauthorized
    end
  end
end
