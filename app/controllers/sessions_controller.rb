class SessionsController < ApplicationController
  def create
    email = params[:email_address].to_s.strip.downcase
    password = params[:password].to_s

    # メールアドレスとパスワードを照合するrailsのメソッド（Rails公式の認証機能）
    user = User.authenticate_by(
      email_address: email,
      password: password
    )

    if user
      render json: {
        token: user.generate_token_for(:api_access)
      }, status: :ok
    else
      render json: {
        error: "Invalid credentials"
      }, status: :unauthorized
    end
  end
end
