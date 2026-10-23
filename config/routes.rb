Rails.application.routes.draw do
  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # ① タスクのCRUD API
  resources :tasks, only: [
    :index,
    :show,
    :create,
    :update,
    :destroy
  ]

  # ② ユーザーごとのタスク取得API
  resources :users, only: [] do
    resources :tasks, only: [ :index ], module: :users
  end

  # ③ ログインAPI
  post "/login", to: "sessions#create"
end
