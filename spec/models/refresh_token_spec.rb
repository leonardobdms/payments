require "rails_helper"

RSpec.describe RefreshToken, type: :model do
  let(:user) { create(:user) }
  let(:refresh_token) do
    create(
      :refresh_token,
      user:,
      token_digest: Digest::SHA256.hexdigest("raw-token")
    )
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(refresh_token).to be_valid
    end

    it "requires token_digest" do
      refresh_token.token_digest = nil

      expect(refresh_token).not_to be_valid
      expect(refresh_token.errors[:token_digest]).to include("can't be blank")
    end

    it "requires a unique token_digest" do
      refresh_token.save!
      duplicate = build(
        :refresh_token,
        user:,
        token_digest: refresh_token.token_digest
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:token_digest]).to include("has already been taken")
    end

    it "requires expires_at" do
      refresh_token.expires_at = nil

      expect(refresh_token).not_to be_valid
      expect(refresh_token.errors[:expires_at]).to include("can't be blank")
    end
  end

  describe "#active?" do
    it "is active when not revoked and not expired" do
      expect(refresh_token).to be_active
    end

    it "is not active when revoked" do
      refresh_token.revoke!

      expect(refresh_token).not_to be_active
    end

    it "is not active when expired" do
      refresh_token.expires_at = 1.minute.ago

      expect(refresh_token).not_to be_active
    end
  end

  describe "#revoke!" do
    it "sets revoked_at" do
      freeze_time do
        refresh_token.revoke!

        expect(refresh_token.revoked_at).to eq(Time.current)
      end
    end
  end
end
