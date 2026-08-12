module Ledger
  class RecordChargeCredit
    def self.call(charge:)
      new(charge:).call
    end

    def initialize(charge:)
      @charge = charge
    end

    def call
      account = charge.merchant.account

      ActiveRecord::Base.transaction do
        account.lock!

        entry = account.ledger_entries.create!(
          charge: charge,
          entry_type: "charge_credit",
          direction: "credit",
          amount_cents: charge.amount_cents,
          currency: charge.currency,
          balance_bucket: "available",
          description: "Charge #{charge.public_id}"
        )

        account.update!(
          available_balance_cents: account.available_balance_cents + charge.amount_cents
        )

        entry
      end
    end

    private

    attr_reader :charge
  end
end
