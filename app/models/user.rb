class User < ApplicationRecord
    has_many :tasks
    #Userから関連するタスクを取得できるようにします
    

    validates :name, presence: true

end
