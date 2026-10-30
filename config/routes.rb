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



  # ブラウザのログイン・ログアウト
  get "/web/login", to: "web/sessions#new", as: :web_login
  post "/web/login", to: "web/sessions#create", as: :web_session
  delete "/web/logout", to: "web/sessions#destroy", as: :web_logout

  # タスク一覧
  get "/dashboard", to: "web/tasks#index", as: :dashboard

  # 新規作成
  get "/dashboard/tasks/new", to: "web/tasks#new", as: :new_dashboard_task
  post "/dashboard/tasks", to: "web/tasks#create", as: :dashboard_tasks

  # 詳細・編集・削除
  get "/dashboard/tasks/:id/edit", to: "web/tasks#edit", as: :edit_dashboard_task
  get "/dashboard/tasks/:id", to: "web/tasks#show", as: :dashboard_task
  patch "/dashboard/tasks/:id", to: "web/tasks#update"
  delete "/dashboard/tasks/:id", to: "web/tasks#destroy"
end
