class Charge < ApplicationRecord
  PUBLIC_ID_PREFIX = "ch_"

  belongs_to :merchant
  has_many :ledger_entries, dependent: :destroy

  monetize :amount_cents

  enum :status, {
    pending: "pending",
    processing: "processing",
    succeeded: "succeeded",
    failed: "failed",
    canceled: "canceled"
  }

  enum :payment_method, { pix: "pix", card: "card" }

  validates :public_id, presence: true, uniqueness: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[BRL] }
  validates :payment_method, presence: true
  validates :provider, presence: true

  before_validation :assign_public_id, on: :create
  before_validation :ensure_metadata

  scope :newest_first, -> { order(created_at: :desc) }

  def cancelable?
    pending? || processing?
  end

  def confirmable?
    processing? && provider == "mock"
  end

  def mark_processing!(provider_ref:)
    update!(status: :processing, provider_ref: provider_ref)
  end

  def succeed!
    raise Charge::InvalidTransition, "charge cannot succeed from #{status}" unless processing?

    transaction do
      update!(status: :succeeded, succeeded_at: Time.current)
      Ledger::RecordChargeCredit.call(charge: self)
    end
  end

  def fail!(reason: nil)
    raise Charge::InvalidTransition, "charge cannot fail from #{status}" unless processing?

    metadata = self.metadata.merge("failure_reason" => reason).compact
    update!(status: :failed, failed_at: Time.current, metadata: metadata)
  end

  def cancel!
    raise Charge::InvalidTransition, "charge cannot be canceled from #{status}" unless cancelable?

    update!(status: :canceled, canceled_at: Time.current)
  end

  class InvalidTransition < StandardError; end

  private

  def assign_public_id
    return if public_id.present?

    loop do
      candidate = "#{PUBLIC_ID_PREFIX}#{SecureRandom.alphanumeric(24)}"
      unless self.class.exists?(public_id: candidate)
        self.public_id = candidate
        break
      end
    end
  end

  def ensure_metadata
    self.metadata = {} if metadata.blank?
  end
end
