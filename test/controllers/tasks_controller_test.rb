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

end
