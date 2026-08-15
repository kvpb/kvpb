class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :comments, dependent: :nullify

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(u) { u.strip }

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                        format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }
  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
end
