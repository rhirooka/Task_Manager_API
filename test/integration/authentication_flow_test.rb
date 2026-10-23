require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Taro",
      email_address: "login-test@example.test",
      password: "TestPass1234!"
    )
  end

  test "正しい認証情報ならログインできる" do
    post "/login",
         params: {
           email_address: @user.email_address,
           password: "TestPass1234!"
         },
         as: :json

    assert_response :ok

    data = JSON.parse(response.body)

    assert data["token"].present?

    authenticated_user = User.find_by_token_for(
      :api_access,
      data["token"]
    )

    assert_equal @user, authenticated_user
  end

  test "間違ったパスワードなら401" do
    post "/login",
         params: {
           email_address: @user.email_address,
           password: "wrong-password"
         },
         as: :json

    assert_response :unauthorized

    data = JSON.parse(response.body)
    assert_equal "Invalid credentials", data["error"]
  end

  test "存在しないユーザーなら401" do
    post "/login",
         params: {
           email_address: "unknown@example.test",
           password: "TestPass1234!"
         },
         as: :json

    assert_response :unauthorized
  end
end