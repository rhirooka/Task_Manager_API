module Users
  class TasksController < ApplicationController
    def index
      user = User.find_by(id: params[:user_id])

      unless user
        render json: {
          error: "User not found"
        }, status: :not_found
        return
      end

      render json: user.tasks
    end
  end
end