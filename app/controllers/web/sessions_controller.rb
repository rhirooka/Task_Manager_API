module Web
  class SessionsController < BaseController
    skip_before_action :require_login, only: %i[new create]

    def new
      redirect_to dashboard_path if current_web_user
    end

    def create
      user = User.authenticate_by(
        email_address: params[:email_address].to_s.strip.downcase,
        password: params[:password].to_s
      )

      if user
        reset_session
        session[:web_user_id] = user.id

        redirect_to dashboard_path, status: :see_other
      else
        @login_error = "メールアドレスまたはパスワードが正しくありません"
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      reset_session
      redirect_to web_login_path, status: :see_other
    end
  end
end
