require "rails_helper"

RSpec.describe Charges::Create do
  let(:merchant) { create(:merchant) }

  it "creates a pix charge in processing with mock metadata" do
    charge = described_class.call(
      merchant:,
      params: {
        amount_cents: 15_00,
        payment_method: "pix",
        description: "Pedido #1"
      }
    )

    expect(charge).to be_processing
    expect(charge.provider_ref).to start_with("mock_")
    expect(charge.metadata).to have_key("mock_pix")
  end

  it "auto-succeeds card charges and credits the wallet" do
    charge = described_class.call(
      merchant:,
      params: {
        amount_cents: 20_00,
        payment_method: "card"
      }
    )

    expect(charge).to be_succeeded
    expect(merchant.account.reload.available_balance_cents).to eq(20_00)
  end

  it "rejects inactive merchants" do
    merchant.update!(status: :suspended)

    expect do
      described_class.call(merchant:, params: { amount_cents: 10_00, payment_method: "pix" })
    end.to raise_error(Charges::Create::MerchantInactiveError)
  end
end
