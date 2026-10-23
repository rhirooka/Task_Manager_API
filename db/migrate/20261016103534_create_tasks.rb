class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.boolean :completed, default: false, null: false
      # ↑今回，デモでタスク管理アプリを作成するので，タスクを登録した直後は「未完了」にしたいため
      # default: false は初期値の設定
      # null: false はNULLを禁止する制約

      t.timestamps
    end
  end
end
