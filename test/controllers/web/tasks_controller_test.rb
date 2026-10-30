require "test_helper"

module Web
    class TaskControllerTest<ActionDispatch::IntegrationTest
        setup do
            @user=User.create!(
                name: "Taro",
                email_address: "web-taro@example.test",
                password: "TestPass1234!"
            )

            @other_user=User.create!(
                name: "Hanako",
                email_address: "web-hanako@example.test",
                password: "TestPass1234!"
            )

            @task=@user.tasks.create!(
                title: "Viewの勉強",
                completed: false
            )

            @other_task=@other_user.tasks.create!(
                title: "他人のタスク",
                completed: false
            )

            credentials=
                ActionController::HttpAuthentication::Basic.encode_credentials(
                    @user.email_address,
                    "TestPass1234!"
            )

            @headers={
                "Authorization"=>credentials
            }
        end

        test "本人のタスク一覧を表示できる" do
            # Taroとして認証情報を送って画面を取得する操作を再現
            get "/dashboard", headers: @headers

            # HTTPレスポンスが 200 OK であることを確認するテスト
            assert_response :ok

            # Taroのタスクが画面に表示されているかを検証
            assert_includes response.body, "Viewの勉強"
            refute_includes response.body, "他人のタスク"
        end

        test "認証無しでは画面を表示できない" do
            get "/dashboard"

            assert_response :unauthorized
        end

        test "本人のタスク詳細を表示できる" do
            get "/dashboard/tasks/#{@task.id}",
                headers: @headers

            assert_response :ok
            assert_includes response.body, "Viewの勉強"
        end

        test "他人のタスク詳細は取得できない" do
            get "/dashboard/tasks/#{@other_task.id}",
                headers: @headers

            assert_response :not_found
        end
    end
end
