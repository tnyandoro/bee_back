class TicketsController < ApplicationController
  before_action :set_organization
  before_action :set_creator, only: [:create]
  before_action :set_ticket, only: %i[show update destroy]

  # GET /organizations/:organization_id/tickets
  def index
    @tickets = @organization.tickets
    render json: @tickets
  end

  # GET /organizations/:organization_id/tickets/:id
  def show
    render json: @ticket
  end

  # POST /organizations/:organization_id/tickets
  def create
    @ticket = @organization.tickets.new(ticket_params)
    @ticket.creator = @creator # Set the creator of the ticket
    @ticket.requester = @creator # Set the requester to the creator by default (can be overridden in params)

    if @ticket.save
      render json: @ticket, status: :created, location: organization_ticket_url(@organization, @ticket)
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/:organization_id/tickets/:id
  def update
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/:organization_id/tickets/:id
  def destroy
    @ticket.destroy!
    head :no_content
  end

  private

  # Set the organization based on the organization_id in the URL
  def set_organization
    @organization = Organization.find(params[:organization_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Organization not found' }, status: :not_found
  end

  # Set the creator of the ticket (current user)
  def set_creator
    @creator = current_user
    unless @creator
      render json: { error: "User not authenticated" }, status: :unauthorized
    end
  end

  # Set the ticket based on the ticket ID and organization
  def set_ticket
    @ticket = @organization.tickets.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Ticket not found' }, status: :not_found
  end

  # Only allow a list of trusted parameters through
  def ticket_params
    params.require(:ticket).permit(
      :title, :description, :ticket_type, :status, :urgency, :priority, :impact,
      :assignee_id, :team_id, :category, :caller_name, :caller_surname, :caller_email,
      :caller_phone, :customer, :source, :reported_at, :requester_id # Allow requester_id to be overridden
    ).tap do |ticket_params|
      # Ensure required fields are present
      required_fields = [
        :title, :description, :ticket_type, :status, :urgency, :priority, :impact,
        :team_id, :category, :caller_name, :caller_surname, :caller_email, :caller_phone,
        :customer, :source, :reported_at
      ]
      required_fields.each do |field|
        ticket_params.require(field) # Raise ActionController::ParameterMissing if any required field is missing
      end
    end
  end
end