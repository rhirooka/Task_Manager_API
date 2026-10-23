require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "正しいパスワードで認証できる" do
    user = User.create!(
      name: "Taro",
      email_address: "model-test@example.test",
      password: "TestPass1234!"
    )

    assert_equal user, user.authenticate("TestPass1234!")
  end

  test "間違ったパスワードは拒否される" do
    user = User.create!(
      name: "Taro",
      email_address: "model-test@example.test",
      password: "TestPass1234!"
    )

    assert_equal false, user.authenticate("wrong-password")
  end

  test "不正なトークンはユーザーを返さない" do
    assert_nil User.find_by_token_for(
      :api_access,
      "invalid-token"
    )
  end
end
