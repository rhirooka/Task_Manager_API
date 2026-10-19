# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server


Rails.application.routes.draw do
    resources :tasks, only: [:index, :show, :create, :update, :destroy]
    #resources :tasks　は，RailsのRESTfulなルーティングをまとめて作成する仕組み

    #今回の only: によって、必要な5種類のアクションだけを生成
    #HTTPメソッド	URL	    アクション	役割
    #GET	    /tasks	    index	一覧取得
    #GET	    /tasks/:id	show	詳細取得
    #POST	    /tasks	    create	新規作成
    #PATCH	    /tasks/:id	update	更新
    #DELETE	    /tasks/:id	destroy	削除

    #Railsでは、同じURLでもHTTPメソッドによって処理を区別できる
    #例えば、/tasks/1 に対してGETを送ると取得、DELETEを送ると削除になる

end

