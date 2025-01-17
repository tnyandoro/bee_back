class TicketsController < ApplicationController
  before_action :set_ticket, only: %i[show update destroy]

  # GET /tickets
  def index
    valid_statuses = %w[open assigned escalated closed suspended resolved]

    # Validate the status query parameter
    if params[:status].present? && !valid_statuses.include?(params[:status])
      return render json: { error: 'Invalid status. Allowed values are: open, assigned, escalated, closed, suspended, resolved.' }, status: :unprocessable_entity
    end

    # Fetch tickets for a specific organization
    if params[:organization_id].present?
      @tickets = Ticket.where(organization_id: params[:organization_id])

      # Filter tickets by user if user_id is provided
      @tickets = @tickets.where(user_id: params[:user_id]) if params[:user_id].present?

      # Filter tickets by status if provided
      @tickets = @tickets.where(status: params[:status]) if params[:status].present?

      render json: @tickets
    else
      render json: { error: 'organization_id is required.' }, status: :unprocessable_entity
    end
  end

  # GET /tickets/1
  def show
    render json: @ticket
  end

  # POST /tickets
  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      render json: @ticket, status: :created, location: @ticket
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tickets/1
  def update
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/1
  def destroy
    @ticket.destroy!
    head :no_content
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority, :user_id, :organization_id)
  end
end
