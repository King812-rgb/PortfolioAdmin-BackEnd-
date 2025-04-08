class Work < ApplicationRecord
  # UUIDを使用するための設定
  self.primary_key = "id"

  # バリデーション
  validates :title, presence: true
  validates :description, presence: true
  validates :tech_stack, presence: true
  validates :screenshot_url, presence: true
  validates :site_url, presence: true
  validates :github_url, presence: true
  validates :released_on, presence: true
  validates :user_id, presence: true

  # 関連
  belongs_to :user
end
