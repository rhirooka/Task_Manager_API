class TasksController < ApplicationController

#GET /tasks　　タスク一覧を返す
def index
    tasks=Task.all
    
    if params.key?(:completed)
    #completed というパラメータが存在する場合だけ、条件検索を行う
        completed_param=params[:completed]
        
        unless ["true", "false"].include?(completed_param)
            render json: {
                error: "completed must be true or false"
            }, status: :bad_request
            return
            #上記のrender json:{} によって，400 Bad Requestを返します
        end

        completed=completed_param=="true"
        tasks=tasks.where(completed: completed)
    end


    render json: tasks

end


#GET /tasks/:id　　特定のタスクを返す
def show
    task=Task.find_by(id: params[:id])

    if task
        render json: task
    else
        render json: { error: "Task not found" }, status: :not_found
    end
end


#POST /tasks　　新しいタスクを作成する
def create
    task=Task.new(task_params)

    if task.save
        render json: task, status: :created
    else
        render json: { errors: task.errors.full_messages }, status: :unprocessable_content
    end
end


#PATCH /tasks/:id　　特定のタスクを更新
def update
    task=Task.find_by(id: params[:id])
    
    unless task
        render json: { error: "Task not found"}, status: :not_found
        return
    end

    if task.update(task_params)
        render json: task
    else
        render json: { errors: task.errors.full_messages },status: :unprocessable_content
    end
end


#DELETE /tasks/:id 　特定のタスクを削除
def destroy
    task = Task.find_by(id: params[:id])

    unless task
      render json: { error: "Task not found" }, status: :not_found
      return
    end

    task.destroy!
    head :no_content
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :completed)
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