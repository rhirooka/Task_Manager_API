Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :tasks, only: [
    :index,
    :show,
    :create,
    :update,
    :destroy
  ]


  Rails.application.routes.draw do
    resources :tasks, only: [
      :index,
      :show,
      :create,
      :update,
      :destroy,
      :new,
      :edit
    ]

    resources :users, only: [] do
      resources :tasks, only: [:index], module: :users
    end
    #ネストしたルーティング（Nested Resources）：User に属する Task という関係をURLにも表しています

  end


end
