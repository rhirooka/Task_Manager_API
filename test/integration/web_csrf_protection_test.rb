
require "test_helper"

class WebCsrfProtectionTest < ActionDispatch::IntegrationTest
  setup do
    @original_setting = Web::BaseController.allow_forgery_protection
    Web::BaseController.allow_forgery_protection = true

    @user = User.create!(
      name: "Security Test User",
      email_address: "csrf-test@example.test",
      password: "TestPass1234!"
    )
  end

  teardown do
    Web::BaseController.allow_forgery_protection = @original_setting
  end

  test "CSRFトークンがないログインPOSTは拒否される" do
    post web_session_path, params: {
      email_address: @user.email_address,
      password: "TestPass1234!"
    }

    assert_response :unprocessable_entity
  end

  test "正しいCSRFトークンがあればログインできる" do
    get web_login_path
    assert_response :ok

    document = Nokogiri::HTML(response.body)
    meta = document.at_css('meta[name="csrf-token"]')

    assert_not_nil meta
    token = meta["content"]

    post web_session_path,
         params: {
           email_address: @user.email_address,
           password: "TestPass1234!"
         },
         headers: {
           "X-CSRF-Token" => token
         }

    assert_redirected_to dashboard_path
  end
end
