class Task < ApplicationRecord
    # Taskクラスを定義している
    # ApplicationRecodeを継承することで，ActivateRecordによるDB操作などの機能を利用できるようになる

    belongs_to :user, optional: true
    # TaskモデルとUserモデルの関連付けを定義

    validates :title, presence: true
  # タイトルが空のタスクを保存できないようにしている
end
