require "rails_helper"

RSpec.describe AuthToken::Token do
  describe ".encode / .decode" do
    it "round-trips a payload with HS256" do
      token = described_class.encode({ user_id: 42 })
      header = JWT.decode(token, nil, false).last

      expect(header["alg"]).to eq("HS256")

      decoded = described_class.decode(token)
      expect(decoded[:user_id]).to eq(42)
      expect(decoded[:exp]).to be_present
    end

    it "uses a 15-minute access token TTL by default" do
      freeze_time do
        token = described_class.encode({ user_id: 42 })
        decoded = described_class.decode(token)

        expect(decoded[:exp]).to eq(15.minutes.from_now.to_i)
      end
    end

    it "returns nil for an invalid token" do
      expect(described_class.decode("invalid.token")).to be_nil
    end
  end
end
