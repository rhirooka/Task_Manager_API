class User < ApplicationRecord
  has_many :tasks
  # Userから関連するタスクを取得できるようにします

  validates :name, presence: true

  has_secure_password
  # パスワードのハッシュ化、認証、基本的なパスワード検証を利用できるようにします

  normalizes :email_address, with: ->(email) {
    email.strip.downcase
  }
  # メールアドレスを正規化している（ex:大文字入力を全て小文字に統一させる処理）

  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false }

  generates_token_for :api_access, expires_in: 1.hour do
    password_salt&.last(10)
    # 1時間で期限切れになる署名付きトークンを発行するための設定
  end
  # Railsの署名付きトークンを発行・検証する設定
end
