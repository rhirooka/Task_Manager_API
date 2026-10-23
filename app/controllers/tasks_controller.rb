class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :update, :destroy]

  def index
    tasks = current_user.tasks

    if params.key?(:completed)
      value = params[:completed]

      unless ["true", "false"].include?(value)
        render json: {
          error: "completed must be true or false"
        }, status: :bad_request
        return
      end

      tasks = tasks.where(completed: value == "true")
    end

    render json: tasks.order(:id)
  end

  def show
    render json: @task
  end

  def create
    task = current_user.tasks.new(task_params)

    if task.save
      render json: task, status: :created
    else
      render json: {
        errors: task.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  def update
    if @task.update(task_params)
      render json: @task, status: :ok
    else
      render json: {
        errors: @task.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  def destroy
    @task.destroy!
    head :no_content
  end

  private

  def set_task
    @task = current_user.tasks.find_by(id: params[:id])

    unless @task
      render json: {
        error: "Task not found"
      }, status: :not_found
    end
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :completed
    )
  end
end

=begin
※ここに書いた文章やコードは，すべてコメントアウトされます

・tasks = Task.all
DBに保存されているすべてのタスクを取得

・render json: tasks
取得したデータをJSON形式のHTTPレスポンスとして返す

・Task.find_by(id: params[:id])
URLで指定されたIDを使用して，DBからタスクを検索

・if task.save
バリデーションを確認した上でDBに保存を試みる

・params.require(:task).permit(:title, :description, :completed)
クライアントが送信したパラメータのうち，一括代入に許可する項目を限定
これは，意図しない属性の書き換えを防ぐための重要な仕組み


=end