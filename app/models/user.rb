class User < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_password
  has_many :refresh_tokens, dependent: :destroy
  has_many :merchants, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, format: { with: /\A[\p{L}\p{M}]+(?:[\p{L}\p{M} '\-’.]*[\p{L}\p{M}])?\.?\z/u }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :cpf, presence: true, uniqueness: true

  # validators gem
  validates_email :email
  validates_cpf :cpf
end
