class Account < ApplicationRecord
  belongs_to :merchant

  monetize :available_balance_cents
  monetize :pending_balance_cents

  validates :currency, presence: true, inclusion: { in: %w[BRL] }
  validates :available_balance_cents,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pending_balance_cents,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
