



require "test_helper"

module Users
  class TasksControllerTest < ActionDispatch::IntegrationTest

    test "指定したユーザーのタスクだけを取得できる" do
      taro = User.create!(name: "Taro")
      hanako = User.create!(name: "Hanako")

      taro_task = taro.tasks.create!(title: "Rubyの勉強")
      hanako.tasks.create!(title: "SQLの勉強")

      get "/users/#{taro.id}/tasks"

      assert_response :ok

      data = JSON.parse(response.body)
      ids = data.map { |task| task["id"] }

      assert_equal [taro_task.id], ids
    end

    test "ユーザーが存在しなければ404を返す" do
      get "/users/999999/tasks"

      assert_response :not_found
    end

    test "タスクが0件でも200を返す" do
      user = User.create!(name: "NoTasks")

      get "/users/#{user.id}/tasks"

      assert_response :ok
      assert_equal [], JSON.parse(response.body)
    end

  end
end