module Users
  class TasksController < ApplicationController
    before_action :authenticate_user!

    def index
      user = User.find_by(id: params[:user_id])

      unless user
        render json: {
          error: "User not found"
        }, status: :not_found
        return
      end

      unless user.id == current_user.id
        render json: {
          error: "Forbidden"
        }, status: :forbidden
        return
      end

      render json: current_user.tasks
    end
  end
end