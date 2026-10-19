class Task < ApplicationRecord
    #Taskクラスを定義している
    #ApplicationRecodeを継承することで，ActivateRecordによるDB操作などの機能を利用できるようになる

    validates :title, presence: true
    #タイトルが空のタスクを保存できないようにしている


end
