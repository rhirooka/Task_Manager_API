
module Web
  class TasksController < BaseController
    before_action :set_task, only: %i[show edit update destroy]

    def index
      @tasks = current_web_user.tasks.order(created_at: :desc)
      @completed_count = @tasks.where(completed: true).count
    end

    def show
    end

    def new
      @task = current_web_user.tasks.new
    end

    def create
      @task = current_web_user.tasks.new(task_params)

      if @task.save
        redirect_to dashboard_path, status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @task.update(task_params)
        redirect_to dashboard_task_path(@task), status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @task.destroy!
      redirect_to dashboard_path, status: :see_other
    end

    private

    def set_task
      @task = current_web_user.tasks.find(params[:id])
    end

    def task_params
      params.require(:task).permit(
        :title,
        :description,
        :completed
      )
    end
  end
end
