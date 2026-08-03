require "rails_helper"

RSpec.describe AuthToken do
  describe ".encode / .decode" do
    it "round-trips a payload with RS256" do
      token = described_class.encode({ user_id: 42 })
      header = JWT.decode(token, nil, false).last

      expect(header["alg"]).to eq("RS256")

      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(42)
      expect(decoded[:exp]).to be_present
    end

    it "returns nil for an invalid token" do
      expect(described_class.decode("invalid.token")).to be_nil
    end
  end
end
