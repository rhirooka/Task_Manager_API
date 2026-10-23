require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
#Railsが提供するHTTPリクエストを含む結合テストの仕組み
#Railsアプリケーションに対するリクエストをテストコードから実行できる

  # test "the truth" do
  #   assert true
  # end
  #タスク一覧を取得できることを確認
  test "task一覧を取得できる" do
    get "/tasks"
    #GETリクエストを送る処理

    assert_response :ok
    #HTPレスポンスが成功ステータス（200〜299）であることを確認
  end


  test "タスクを作成できる" do
  assert_difference "Task.count", 1 do
    #ブロックの実行前と実行後でTask.countが１増えることを確認

  # もしPOSTが201を返しても、DBにデータが保存されていなければ、このテストは失敗します。
  #レスポンスだけでなく、DBの状態も確認していることが重要
   
    post "/tasks",
      params: {
        task: {
          title: "SQLの勉強",
          completed: false
        }
      },
      as: :json
  end

  assert_response :created
end


test "タイトルが空ならタスクを作成できない" do
  assert_no_difference "Task.count" do
    post "/tasks",
      params: {
        task: {
          title: ""
        }
      },
      as: :json
  end

  assert_response :unprocessable_content
end


test "タスクを更新できる" do
  task = Task.create!(
    title: "Rubyの勉強",
    completed: false
  )

  patch "/tasks/#{task.id}",
    params: {
      task: {
        completed: true
      }
    },
    as: :json

  assert_response :ok

  assert task.reload.completed?
end

test "タスクを削除できる" do
  task = Task.create!(
    title: "削除用タスク"
  )

  assert_difference "Task.count", -1 do
    delete "/tasks/#{task.id}"
  end

  assert_response :no_content
end

test "存在しないタスクは404になる" do
  get "/tasks/999999"

  assert_response :not_found
end

test "未完了のタスクだけを取得できる" do
  incomplete = Task.create!(
    title: "未完了タスク",
    completed: false
  )

  completed = Task.create!(
    title: "完了タスク",
    completed: true
  )

  get "/tasks", params: { completed: "false" }

  assert_response :ok

  ids = JSON.parse(response.body).map { |task| task["id"] }

  assert_includes ids, incomplete.id
  assert_not_includes ids, completed.id
end

test "完了済みのタスクだけを取得できる" do
  incomplete = Task.create!(
    title: "未完了タスク",
    completed: false
  )

  completed = Task.create!(
    title: "完了タスク",
    completed: true
  )

  get "/tasks", params: { completed: "true" }

  assert_response :ok

  ids = JSON.parse(response.body).map { |task| task["id"] }

  assert_includes ids, completed.id
  assert_not_includes ids, incomplete.id
end

test "不正なcompletedパラメータは400を返す" do
  get "/tasks", params: { completed: "abc" }

  assert_response :bad_request


end


test "存在しないタスクは更新できない" do
  patch "/tasks/999999",
    params: {
      task: {
        completed: true
      }
    },
    as: :json

  assert_response :not_found

  response_json = JSON.parse(response.body)

  assert_equal "Task not found", response_json["error"]
  #期待する値と実際の値が一致することを確認するメソッド
end

test "存在しないタスクは削除できない" do
  delete "/tasks/999999"

  assert_response :not_found

  response_json = JSON.parse(response.body)

  assert_equal "Task not found", response_json["error"]
end


test "タイトルを空に更新できない" do
  task = Task.create!(
    title: "Rubyの勉強",
    completed: false
  )

  patch "/tasks/#{task.id}",
    params: {
      task: {
        title: ""
      }
    },
    as: :json

  assert_response :unprocessable_content

  assert_equal "Rubyの勉強", task.reload.title #DBからタスクの最新のデータを読み直して、そのタイトルを取得する処理
end



end
