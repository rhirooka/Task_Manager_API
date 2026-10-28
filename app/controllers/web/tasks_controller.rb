module Web
  # 通常のHTMLテンプレートを描写する機能を利用するためのcontroller
  class TasksController < ActionController::Base
    layout "web"

    before_action :authenticate_web_user!

    # 認証されたユーザのタスクを取得
    def index
      @tasks = @current_user.tasks.order(created_at: :desc)
      @completed_count = @tasks.where(completed: true).count
      # @マークがついたインスタンス変数はcontrollerからviewにデータを渡す際に利用できる
    end

    # 本人のタスクだけを検索して，存在しなければ404を返す
    def show
      @task = @current_user.tasks.find_by(id: params[:id])

      head :not_found unless @task
    end

    private

    def authenticate_web_user!
      authenticate_or_request_with_http_basic("Task Manager") do |email, password|
        @current_user = User.authenticate_by(
          email_address: email.to_s.strip.downcase,
          password: password
        )

        @current_user.present?
      end
    end
  end
end
