class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :authorize_admin_or_super_user, except: [:index, :show]
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  # GET /teams
  def index
    @teams = @organization.teams
  end

  # GET /teams/:id
  def show
  end

  # GET /teams/new
  def new
    @team = @organization.teams.new
  end

  # POST /teams
  def create
    @team = @organization.teams.new(team_params)
    if @team.save
      redirect_to organization_team_path(@organization, @team), notice: "Team was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /teams/:id/edit
  def edit
  end

  # PATCH/PUT /teams/:id
  def update
    if @team.update(team_params)
      redirect_to organization_team_path(@organization, @team), notice: "Team was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /teams/:id
  def destroy
    @team.destroy
    redirect_to organization_teams_path(@organization), notice: "Team was successfully deleted."
  end

  private

  # Set the organization for all actions
  def set_organization
    @organization = current_user.organization
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = @organization.teams.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def team_params
    params.require(:team).permit(:name)
  end

  # Ensure only admins and super_users can create, update, or delete teams.
  def authorize_admin_or_super_user
    unless current_user.can_create_teams?
      redirect_to organization_teams_path(@organization), alert: "You are not authorized to perform this action."
    end
  end
end