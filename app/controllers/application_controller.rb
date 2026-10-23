class ApplicationController < ActionController::API
  private

  attr_reader :current_user

  def authenticate_user!
    authorization = request.headers["Authorization"].to_s

    token = authorization[/\ABearer (\S+)\z/i, 1]

    @current_user = User.find_by_token_for(:api_access, token) if token

    return if @current_user

    render json: {
      error: "Unauthorized"
    }, status: :unauthorized
  end
end