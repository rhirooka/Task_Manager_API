class AddAuthenticationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_address, :string
    add_column :users, :password_digest, :string

    add_index :users, :email_address, unique: true
    # メールアドレスを使った検索を効率化し、同じメールアドレスを重複登録できないようにするDBの制約
  end
end
