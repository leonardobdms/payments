class Merchant < ApplicationRecord
  belongs_to :user
  has_one :account, dependent: :destroy
  has_many :charges, dependent: :destroy

  validates :legal_name, presence: true
  validates :document, presence: true, uniqueness: true

  validates_cnpj_format_of :document

  enum :status, { active: "active", suspended: "suspended", closed: "closed" }

  after_create :create_default_account

  private

  def create_default_account
    create_account!(currency: "BRL")
  end
end
