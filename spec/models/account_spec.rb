require "rails_helper"

RSpec.describe Account, type: :model do
  subject(:account) { create(:merchant).account }

  describe "validations" do
    it "is valid with default attributes" do
      expect(account).to be_valid
    end

    it "does not allow negative available balance" do
      account.available_balance_cents = -1

      expect(account).not_to be_valid
      expect(account.errors[:available_balance_cents]).to be_present
    end

    it "does not allow negative pending balance" do
      account.pending_balance_cents = -1

      expect(account).not_to be_valid
      expect(account.errors[:pending_balance_cents]).to be_present
    end
  end

  describe "money-rails" do
    it "exposes Money objects for balances" do
      account.update!(available_balance_cents: 1500, pending_balance_cents: 500)

      expect(account.available_balance).to eq(Money.new(1500, "BRL"))
      expect(account.pending_balance).to eq(Money.new(500, "BRL"))
    end
  end
end
