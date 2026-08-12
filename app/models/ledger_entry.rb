class LedgerEntry < ApplicationRecord
  self.record_timestamps = false

  belongs_to :account
  belongs_to :charge, optional: true

  ENTRY_TYPES = %w[
    charge_credit
    charge_pending
    charge_release
    refund_debit
    adjustment
  ].freeze

  DIRECTIONS = %w[credit debit].freeze
  BALANCE_BUCKETS = %w[available pending].freeze

  validates :entry_type, presence: true, inclusion: { in: ENTRY_TYPES }
  validates :direction, presence: true, inclusion: { in: DIRECTIONS }
  validates :balance_bucket, presence: true, inclusion: { in: BALANCE_BUCKETS }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, presence: true, inclusion: { in: %w[BRL] }

  before_create :set_created_at

  private

  def set_created_at
    self.created_at = Time.current
  end
end
