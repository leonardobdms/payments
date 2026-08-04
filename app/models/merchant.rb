class Merchant < ApplicationRecord
  STATUSES = %w[active suspended closed].freeze

  belongs_to :user
  has_one :account, dependent: :destroy

  validates :legal_name, presence: true
  validates :document, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validate :document_must_be_valid_cpf_or_cnpj

  before_validation :normalize_document

  after_create :create_default_account

  def as_json(options = {})
    super(
      options.merge(
        only: %w[id legal_name document status],
        include: { account: { only: %w[currency available_balance_cents pending_balance_cents] } }
      )
    )
  end

  private

  def create_default_account
    create_account!(currency: "BRL")
  end

  def normalize_document
    return if document.blank?

    self.document = document.gsub(/\D/, "")
  end

  def document_must_be_valid_cpf_or_cnpj
    return if document.blank?

    return if ::CPF.valid?(document) || ::CNPJ.valid?(document)

    errors.add(:document, "is not a valid CPF or CNPJ")
  end
end
