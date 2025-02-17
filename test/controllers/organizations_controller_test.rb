require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
  end

  test "should get index" do
    get api_v1_organizations_url, as: :json
    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      post api_v1_organizations_url, 
        params: { organization: { 
          address: "New Address",
          email: "new_org@example.com",
          name: "New Organization",
          subdomain: "neworg",
          web_address: "http://neworg.com"
        } }, 
        as: :json
    end

    assert_response :created
  end

  test "should show organization" do
    get api_v1_organization_url(subdomain: @organization.subdomain), as: :json
    assert_response :success
  end

  test "should update organization" do
    patch api_v1_organization_url(subdomain: @organization.subdomain), 
      params: { organization: { 
        address: "Updated Address",
        email: "updated@example.com",
        name: "Updated Org",
        subdomain: @organization.subdomain,
        web_address: "http://updatedorg.com"
      } }, 
      as: :json

    assert_response :success
  end

  test "should destroy organization" do
    assert_difference("Organization.count", -1) do
      delete api_v1_organization_url(subdomain: @organization.subdomain), as: :json
    end

    assert_response :no_content
  end

  test "should return 404 for non-existent organization" do
    get api_v1_organization_url(subdomain: "nonexistent"), as: :json
    assert_response :not_found
  end
end
