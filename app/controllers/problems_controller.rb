class ProblemsController < ApplicationController
  before_action :set_problem, only: %i[show update destroy]

  def index
    if params[:organization_id]
      @organization = Organization.find(params[:organization_id])
      @problems = @organization.problems
    else
      @problems = Problem.all
    end

    render json: @problems
  end

  # GET /problems/1
  def show
    render json: @problem
  end

  # POST /problems
  def create
    @problem = Problem.new(problem_params)

    if @problem.save
      render json: @problem, status: :created, location: @problem
    else
      render json: @problem.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /problems/1
  def update
    if @problem.update(problem_params)
      render json: @problem
    else
      render json: @problem.errors, status: :unprocessable_entity
    end
  end

  # DELETE /problems/1
  def destroy
    @problem.destroy!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_problem
    @problem = Problem.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def problem_params
    params.require(:problem).permit(:description, :ticket_id, :organization_id)
  end
end
