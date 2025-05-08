require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Assuming fixtures or factories for users
    @user = users(:one) # Regular user
    @admin = users(:admin) # Admin user
    @subdomain = "demo" # Matches frontend's development fallback
    @host = "#{@subdomain}.lvh.me"
  end

  test "should authenticate with valid credentials" do
    post api_v1_login_url,
         params: { email: @user.email, password: "password" },
         headers: { "Host" => @host },
         as: :json
    assert_response :success
    response_body = JSON.parse(response.body)
    assert_not_nil response_body["auth_token"], "Response should include auth_token"
    assert_equal "Login successful", response_body["message"]
    # Verify user has updated auth_token
    @user.reload
    assert_equal response_body["auth_token"], @user.auth_token
  end

  test "should not authenticate with invalid credentials" do
    post api_v1_login_url,
         params: { email: @user.email, password: "wrong_password" },
         headers: { "Host" => @host },
         as: :json
    assert_response :unauthorized
    response_body = JSON.parse(response.body)
    assert_equal "Invalid email or password", response_body["error"]
    assert_nil response_body["auth_token"], "Response should not include auth_token"
  end

  test "should verify authenticated user" do
    token = generate_token_for(@user)
    get api_v1_verify_url,
        headers: { "Host" => @host, "Authorization" => "Bearer #{token}" },
        as: :json
    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal @user.email, response_body["user"]["email"]
    assert_equal "User verified", response_body["message"]
  end

  test "should verify admin user" do
    token = generate_token_for(@admin)
    get api_v1_verify_admin_url,
        headers: { "Host" => @host, "Authorization" => "Bearer #{token}" },
        as: :json
    assert_response :success
    response_body = JSON.parse(response.body)
    assert_equal @admin.email, response_body["user"]["email"]
    assert_equal true, response_body["user"]["is_admin"]
    assert_equal "Admin verified", response_body["message"]
  end

  test "should not verify with invalid token" do
    get api_v1_verify_url,
        headers: { "Host" => @host, "Authorization" => "Bearer invalid_token" },
        as: :json
    assert_response :unauthorized
    response_body = JSON.parse(response.body)
    assert_equal "Invalid or expired token", response_body["error"]
  end

  test "should not verify non-admin for admin endpoint" do
    token = generate_token_for(@user)
    get api_v1_verify_admin_url,
        headers: { "Host" => @host, "Authorization" => "Bearer #{token}" },
        as: :json
    assert_response :forbidden
    response_body = JSON.parse(response.body)
    assert_equal "Admin access required", response_body["error"]
  end

  test "should refresh valid token" do
    token = generate_token_for(@user)
    post api_v1_refresh_token_url,
         headers: { "Host" => @host, "Authorization" => "Bearer #{token}" },
         as: :json
    assert_response :success
    response_body = JSON.parse(response.body)
    assert_not_nil response_body["auth_token"], "Response should include new auth_token"
    assert_equal "Token refreshed", response_body["message"]
    @user.reload
    assert_equal response_body["auth_token"], @user.auth_token
    assert_not_equal token, @user.auth_token, "New token should differ from old token"
  end

  test "should not refresh invalid token" do
    post api_v1_refresh_token_url,
         headers: { "Host" => @host, "Authorization" => "Bearer invalid_token" },
         as: :json
    assert_response :unauthorized
    response_body = JSON.parse(response.body)
    assert_equal "Invalid or expired token", response_body["error"]
    assert_nil response_body["auth_token"], "Response should not include auth_token"
  end

  private

  def generate_token_for(user)
    # Mimics controller's token generation logic
    token = SecureRandom.hex(32)
    user.update!(auth_token: token)
    token
  end
end