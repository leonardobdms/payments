require "rails_helper"

RSpec.describe LedgerEntry, type: :model do
  subject(:entry) do
    build(
      :ledger_entry,
      account: create(:merchant).account,
      charge: create(:charge)
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(entry).to be_valid
    end

    it "requires a positive amount" do
      entry.amount_cents = 0

      expect(entry).not_to be_valid
    end
  end
end
