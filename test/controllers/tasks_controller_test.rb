require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Taro",
      email_address: "taro@example.test",
      password: "TestPass1234!"
    )

    @other_user = User.create!(
      name: "Hanako",
      email_address: "hanako@example.test",
      password: "TestPass1234!"
    )

    @task = @user.tasks.create!(
      title: "Rubyの勉強",
      completed: false
    )

    @other_task = @other_user.tasks.create!(
      title: "SQLの勉強",
      completed: false
    )

    token = @user.generate_token_for(:api_access)

    @headers = {
      "Authorization" => "Bearer #{token}"
    }
  end

  # GET /tasks

  test "本人のタスクだけ取得できる" do
    get "/tasks", headers: @headers

    assert_response :ok

    ids = JSON.parse(response.body).map do |task|
      task["id"]
    end

    assert_equal [@task.id], ids
  end

  test "未完了タスクを検索できる" do
    get "/tasks",
        params: { completed: "false" },
        headers: @headers

    assert_response :ok

    ids = JSON.parse(response.body).map do |task|
      task["id"]
    end

    assert_equal [@task.id], ids
  end

  test "完了タスクを検索できる" do
    completed_task = @user.tasks.create!(
      title: "Railsの勉強",
      completed: true
    )

    get "/tasks",
        params: { completed: "true" },
        headers: @headers

    assert_response :ok

    ids = JSON.parse(response.body).map do |task|
      task["id"]
    end

    assert_equal [completed_task.id], ids
  end

  test "不正な検索条件なら400を返す" do
    get "/tasks",
        params: { completed: "abc" },
        headers: @headers

    assert_response :bad_request
  end

  # GET /tasks/:id

  test "本人のタスク詳細を取得できる" do
    get "/tasks/#{@task.id}", headers: @headers

    assert_response :ok

    data = JSON.parse(response.body)
    assert_equal @task.id, data["id"]
  end

  test "他人のタスク詳細は取得できない" do
    get "/tasks/#{@other_task.id}",
        headers: @headers

    assert_response :not_found
  end

  # POST /tasks

  test "本人のタスクを作成できる" do
    assert_difference "Task.count", 1 do
      post "/tasks",
           params: {
             task: { title: "認証の勉強" }
           },
           headers: @headers,
           as: :json
    end

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal @user.id, data["user_id"]
  end

  test "user_idを偽装しても所有者は変わらない" do
    post "/tasks",
         params: {
           task: {
             title: "認可の勉強",
             user_id: @other_user.id
           }
         },
         headers: @headers,
         as: :json

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal @user.id, data["user_id"]
  end

  test "タイトルが空なら作成できない" do
    assert_no_difference "Task.count" do
      post "/tasks",
           params: {
             task: { title: "" }
           },
           headers: @headers,
           as: :json
    end

    assert_response :unprocessable_content
  end

  # PATCH /tasks/:id

  test "本人のタスクを更新できる" do
    patch "/tasks/#{@task.id}",
          params: {
            task: { completed: true }
          },
          headers: @headers,
          as: :json

    assert_response :ok
    assert_equal true, @task.reload.completed
  end

  test "他人のタスクは更新できない" do
    patch "/tasks/#{@other_task.id}",
          params: {
            task: { completed: true }
          },
          headers: @headers,
          as: :json

    assert_response :not_found
    assert_equal false, @other_task.reload.completed
  end

  test "タイトルを空に更新できない" do
    patch "/tasks/#{@task.id}",
          params: {
            task: { title: "" }
          },
          headers: @headers,
          as: :json

    assert_response :unprocessable_content

    assert_equal "Rubyの勉強", @task.reload.title
  end

  test "更新時に所有者を変更できない" do
    patch "/tasks/#{@task.id}",
          params: {
            task: { user_id: @other_user.id }
          },
          headers: @headers,
          as: :json

    assert_response :ok
    assert_equal @user.id, @task.reload.user_id
  end

  # DELETE /tasks/:id

  test "本人のタスクを削除できる" do
    assert_difference "Task.count", -1 do
      delete "/tasks/#{@task.id}",
             headers: @headers
    end

    assert_response :no_content
  end

  test "他人のタスクは削除できない" do
    assert_no_difference "Task.count" do
      delete "/tasks/#{@other_task.id}",
             headers: @headers
    end

    assert_response :not_found
  end

  # 認証エラー

  test "未認証なら一覧を取得できない" do
    get "/tasks"

    assert_response :unauthorized
  end

  test "未認証ならタスクを作成できない" do
    assert_no_difference "Task.count" do
      post "/tasks",
           params: {
             task: { title: "不正な登録" }
           },
           as: :json
    end

    assert_response :unauthorized
  end

  test "未認証ならタスクを更新できない" do
    patch "/tasks/#{@task.id}",
          params: {
            task: { completed: true }
          },
          as: :json

    assert_response :unauthorized
    assert_equal false, @task.reload.completed
  end

  test "未認証ならタスクを削除できない" do
    assert_no_difference "Task.count" do
      delete "/tasks/#{@task.id}"
    end

    assert_response :unauthorized
  end

  test "不正なトークンは拒否される" do
    get "/tasks",
        headers: {
          "Authorization" => "Bearer invalid-token"
        }

    assert_response :unauthorized
  end
end