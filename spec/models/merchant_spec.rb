require "rails_helper"

RSpec.describe Merchant, type: :model do
  subject(:merchant) { build(:merchant) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(merchant).to be_valid
    end

    it "requires legal_name" do
      merchant.legal_name = nil

      expect(merchant).not_to be_valid
      expect(merchant.errors[:legal_name]).to include("can't be blank")
    end

    it "requires a unique document" do
      existing = create(:merchant)
      merchant.document = existing.document

      expect(merchant).not_to be_valid
      expect(merchant.errors[:document]).to include("has already been taken")
    end

    it "requires a valid CPF or CNPJ document" do
      merchant.document = "12345678901"

      expect(merchant).not_to be_valid
      expect(merchant.errors[:document]).to include("is not a valid CPF or CNPJ")
    end

    it "normalizes document to digits only" do
      merchant.document = "54.550.752/0001-55"

      merchant.valid?

      expect(merchant.document).to eq("54550752000155")
    end
  end

  describe "account creation" do
    it "creates a BRL account after create" do
      merchant = create(:merchant)

      expect(merchant.account).to be_present
      expect(merchant.account.currency).to eq("BRL")
      expect(merchant.account.available_balance_cents).to eq(0)
      expect(merchant.account.pending_balance_cents).to eq(0)
    end
  end
end
