require "rails_helper"

RSpec.describe AuthToken::Refresh do
  describe "#issue" do
    let(:user) { create(:user) }

    it "returns an access token and a refresh token" do
      tokens = described_class.new(user: user).issue

      expect(AuthToken::Token.decode(tokens[:access_token])[:user_id]).to eq(user.id)
      expect(tokens[:refresh_token]).to be_present
      expect(user.refresh_tokens.count).to eq(1)
      expect(user.refresh_tokens.first.token_digest).to eq(
        Digest::SHA256.hexdigest(tokens[:refresh_token])
      )
    end
  end

  describe "#refresh!" do
    let(:user) { create(:user) }
    let!(:tokens) { described_class.new(user: user).issue }

    it "rotates tokens when the refresh token is valid" do
      new_tokens = described_class.new(token: tokens[:refresh_token]).refresh!

      expect(new_tokens[:access_token]).to be_present
      expect(new_tokens[:refresh_token]).to be_present
      expect(new_tokens[:refresh_token]).not_to eq(tokens[:refresh_token])
      expect(AuthToken::Token.decode(new_tokens[:access_token])[:user_id]).to eq(user.id)
      expect(described_class.new(token: tokens[:refresh_token]).refresh!).to be_nil
    end

    it "returns nil for an invalid refresh token" do
      expect(described_class.new(token: "invalid-token").refresh!).to be_nil
    end

    it "returns nil for an expired refresh token" do
      user.refresh_tokens.first.update!(expires_at: 1.minute.ago)

      expect(described_class.new(token: tokens[:refresh_token]).refresh!).to be_nil
    end

    it "returns nil when the token does not belong to the given user" do
      other_user = create(:user)

      expect(
        described_class.new(token: tokens[:refresh_token], user: other_user).refresh!
      ).to be_nil
      expect(user.refresh_tokens.first).not_to be_revoked
    end

    it "issues tokens for the token owner even if another user was passed and matches" do
      new_tokens = described_class.new(token: tokens[:refresh_token], user: user).refresh!

      expect(AuthToken::Token.decode(new_tokens[:access_token])[:user_id]).to eq(user.id)
    end
  end

  describe "#revoke!" do
    let(:user) { create(:user) }
    let!(:tokens) { described_class.new(user: user).issue }

    it "revokes a valid refresh token" do
      expect(described_class.new(token: tokens[:refresh_token]).revoke!).to be(true)
      expect(user.refresh_tokens.first).to be_revoked
      expect(described_class.new(token: tokens[:refresh_token]).refresh!).to be_nil
    end

    it "returns false for an unknown token" do
      expect(described_class.new(token: "unknown").revoke!).to be(false)
    end

    it "returns false when the token does not belong to the given user" do
      other_user = create(:user)

      expect(
        described_class.new(token: tokens[:refresh_token], user: other_user).revoke!
      ).to be(false)
      expect(user.refresh_tokens.first).not_to be_revoked
    end
  end
end
