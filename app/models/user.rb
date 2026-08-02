class User < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, format: { with: /\A[\p{L}\p{M}]+(?:[\p{L}\p{M} '\-’.]*[\p{L}\p{M}])?\.?\z/u }
  validates :password, presence: true, length: { minimum: 8 }
  validates :cpf, presence: true, uniqueness: true

  # validators gem
  validates_email :email
  validates_cpf :cpf
end
