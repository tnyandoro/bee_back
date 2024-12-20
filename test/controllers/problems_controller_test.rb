require "test_helper"

class ProblemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @problem = problems(:one)
  end

  test "should get index" do
    get problems_url, as: :json
    assert_response :success
  end

  test "should create problem" do
    assert_difference("Problem.count") do
      post problems_url, params: { problem: { description: @problem.description, ticket_id: @problem.ticket_id } }, as: :json
    end

    assert_response :created
  end

  test "should show problem" do
    get problem_url(@problem), as: :json
    assert_response :success
  end

  test "should update problem" do
    patch problem_url(@problem), params: { problem: { description: @problem.description, ticket_id: @problem.ticket_id } }, as: :json
    assert_response :success
  end

  test "should destroy problem" do
    assert_difference("Problem.count", -1) do
      delete problem_url(@problem), as: :json
    end

    assert_response :no_content
  end
end
