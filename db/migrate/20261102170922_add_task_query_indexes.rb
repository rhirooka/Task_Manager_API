
class AddTaskQueryIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :tasks, [ :user_id, :created_at ],
              name: "index_tasks_on_user_id_and_created_at",
              if_not_exists: true

    add_index :tasks, [ :user_id, :completed ],
              name: "index_tasks_on_user_id_and_completed",
              if_not_exists: true
  end
end
