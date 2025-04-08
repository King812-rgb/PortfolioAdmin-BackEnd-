class User < ApplicationRecord
  # バリデーション
  validates :id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # 関連
  has_many :works
end
