require "test_helper"

module Users
  class TasksControllerTest < ActionDispatch::IntegrationTest

    def create_user(name, email)
      User.create!(
        name: name,
        email_address: email,
        password: "TestPass1234!"
      )
    end

    def auth_headers(user)
      {
        "Authorization" => "Bearer #{user.generate_token_for(:api_access)}"
      }
    end

    test "本人のタスクだけを取得できる" do
      taro = create_user("Taro", "taro@example.test")
      hanako = create_user("Hanako", "hanako@example.test")

      task = taro.tasks.create!(title: "Rubyの勉強")
      hanako.tasks.create!(title: "SQLの勉強")

      get "/users/#{taro.id}/tasks",
          headers: auth_headers(taro)
          #テスト中のHTTPリクエストにTaroの認証トークンを付ける処理

      assert_response :ok

      data = JSON.parse(response.body)
      ids = data.map { |item| item["id"] }

      assert_equal [task.id], ids
    end

    test "存在しないユーザーは404を返す" do
      taro = create_user("Taro", "taro@example.test")

      get "/users/999999/tasks",
          headers: auth_headers(taro)

      assert_response :not_found
    end

    test "タスクが0件でも200を返す" do
      taro = create_user("Taro", "taro@example.test")

      get "/users/#{taro.id}/tasks",
          headers: auth_headers(taro)

      assert_response :ok
      assert_equal [], JSON.parse(response.body)
    end

    test "トークンがなければ401を返す" do
      taro = create_user("Taro", "taro@example.test")

      get "/users/#{taro.id}/tasks"

      assert_response :unauthorized
    end

    test "不正なトークンなら401を返す" do
      taro = create_user("Taro", "taro@example.test")

      get "/users/#{taro.id}/tasks",
          headers: {
            "Authorization" => "Bearer invalid-token"
          }

      assert_response :unauthorized
    end

    test "他人のタスクは取得できない" do
      taro = create_user("Taro", "taro@example.test")
      hanako = create_user("Hanako", "hanako@example.test")

      get "/users/#{hanako.id}/tasks",
          headers: auth_headers(taro)

      assert_response :forbidden
      #正しくログインしていても、他人のデータを取得できないことを自動的に検証
    end

  end
end