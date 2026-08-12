require "rails_helper"

RSpec.describe Charge, type: :model do
  subject(:charge) { build(:charge) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(charge).to be_valid
    end

    it "requires a positive amount" do
      charge.amount_cents = 0

      expect(charge).not_to be_valid
      expect(charge.errors[:amount_cents]).to be_present
    end

    it "assigns a public_id on create" do
      charge = create(:charge)

      expect(charge.public_id).to start_with("ch_")
    end
  end

  describe "status transitions" do
    it "succeeds from processing and credits the ledger" do
      merchant = create(:merchant)
      charge = create(:charge, :processing, merchant:, amount_cents: 25_00)

      expect { charge.succeed! }
        .to change { merchant.account.reload.available_balance_cents }.by(25_00)
        .and change(LedgerEntry, :count).by(1)

      expect(charge.reload).to be_succeeded
      expect(charge.succeeded_at).to be_present
    end

    it "cancels from pending" do
      charge = create(:charge, status: "pending")

      charge.cancel!

      expect(charge.reload).to be_canceled
      expect(charge.canceled_at).to be_present
    end

    it "raises when canceling a succeeded charge" do
      charge = create(:charge, :succeeded)

      expect { charge.cancel! }.to raise_error(Charge::InvalidTransition)
    end
  end
end
