module Web
  # ActionController::Base　HTML表示・フォームなどの機能を使用
  class BaseController < ActionController::Base
    # web.html.erbを共通レイアウトにする
    layout "web"

    # 不正なフォーム送信を防ぐCSRF対策
    # CSRF対策は、Cookieを使うブラウザ向け認証で特に重要です。
    # Railsではフォームの正当性をトークンで検証できます
    protect_from_forgery with: :exception

    # 各アクションの前に認証を確認
    before_action :require_login

    helper_method :current_web_user

    private

    def current_web_user
      # session[:web_user_id]	ログイン中のユーザーIDを取り出す
      # current_web_user	ログイン中のユーザーを取得
      @current_user ||= User.find_by(id: session[:web_user_id])
    end

    def require_login
      redirect_to web_login_path unless current_web_user
    end
  end
end
