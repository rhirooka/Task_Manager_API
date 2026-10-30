
require "test_helper"

module Web
  class TasksControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = User.create!(
        name: "Taro",
        email_address: "web-taro@example.test",
        password: "TestPass1234!"
      )

      @other_user = User.create!(
        name: "Hanako",
        email_address: "web-hanako@example.test",
        password: "TestPass1234!"
      )

      @task = @user.tasks.create!(
        title: "Viewの勉強",
        completed: false
      )

      @other_task = @other_user.tasks.create!(
        title: "他人のタスク",
        completed: false
      )
    end

    # テスト用のログイン処理
    def sign_in
      post web_session_path, params: {
        email_address: @user.email_address,
        password: "TestPass1234!"
      }

      assert_redirected_to dashboard_path
    end

    test "本人のタスク一覧を表示できる" do
      sign_in
      get dashboard_path

      assert_response :ok
      assert_includes response.body, "Viewの勉強"
      refute_includes response.body, "他人のタスク"
    end

    test "未認証ではダッシュボードを表示できない" do
      get dashboard_path

      assert_redirected_to web_login_path
    end

    test "本人のタスク詳細を表示できる" do
      sign_in
      get dashboard_task_path(@task)

      assert_response :ok
      assert_includes response.body, "Viewの勉強"
    end

    test "他人のタスク詳細は取得できない" do
      sign_in
      get dashboard_task_path(@other_task)

      assert_response :not_found
    end

    test "フォームからタスクを作成できる" do
      sign_in

      assert_difference("Task.count", 1) do
        post dashboard_tasks_path, params: {
          task: {
            title: "フォームから登録",
            description: "Railsの勉強",
            completed: false,
            user_id: @other_user.id
          }
        }
      end

      assert_redirected_to dashboard_path

      task = Task.find_by!(title: "フォームから登録")
      assert_equal @user.id, task.user_id
    end

    test "タイトルが空なら保存できない" do
      sign_in

      assert_no_difference("Task.count") do
        post dashboard_tasks_path, params: {
          task: { title: "", completed: false }
        }
      end

      assert_response :unprocessable_entity
    end

    test "本人のタスクを更新できる" do
      sign_in

      patch dashboard_task_path(@task), params: {
        task: {
          title: "更新したタスク",
          completed: true
        }
      }

      assert_redirected_to dashboard_task_path(@task)
      assert_equal "更新したタスク", @task.reload.title
      assert @task.completed?
    end

    test "他人のタスクは更新できない" do
      sign_in

      patch dashboard_task_path(@other_task), params: {
        task: { title: "不正な更新" }
      }

      assert_response :not_found
      assert_equal "他人のタスク", @other_task.reload.title
    end

    test "本人のタスクを削除できる" do
      sign_in

      assert_difference("Task.count", -1) do
        delete dashboard_task_path(@task)
      end

      assert_redirected_to dashboard_path
    end

    test "未認証ではタスクを作成できない" do
      assert_no_difference("Task.count") do
        post dashboard_tasks_path, params: {
          task: { title: "未認証の登録" }
        }
      end

      assert_redirected_to web_login_path
    end

    test "間違ったパスワードではログインできない" do
      post web_session_path, params: {
        email_address: @user.email_address,
        password: "WrongPassword!"
      }

      assert_response :unprocessable_entity

      get dashboard_path
      assert_redirected_to web_login_path
    end

    test "ログアウトできる" do
      sign_in

      delete web_logout_path
      assert_redirected_to web_login_path

      get dashboard_path
      assert_redirected_to web_login_path
    end
  end
end
