# Taskモデルのテスト

require "test_helper"
# Railsのテスト用設定を読み込む

class TaskTest < ActiveSupport::TestCase
  # Taskモデルのテスト用クラスの定義
  # test "the truth" do
  #   assert true
  # end

  test "titleがあれば有効なタスクになる" do
    # １つのテストケースを定義

    task=Task.new(title: "Rubyの勉強", completed: false)
    # Taskオブジェクトを作成

    assert task.valid?
    # taskが真であることを確認
  end

  # つまり，「タイトルが指定されたタスクは有効である」条件を検証




  test "titleが空なら無効になる" do
    task=Task.new(title: "", completed: false)

    assert_not task.valid?
    # Taskが偽であることを確認
  end
  # つまり，「タイトルが空のタスクは無効である」条件を検証
end
