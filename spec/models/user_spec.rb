require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    describe "email" do
      it "requires email" do
        user.email = nil

        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it "requires a unique email" do
        existing = create(:user)
        user.email = existing.email

        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("has already been taken")
      end

      it "requires a valid email" do
        user.email = "invalid_email"

        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("is not a valid address")
      end
    end

    describe "cpf" do
      it "requires cpf" do
        user.cpf = nil

        expect(user).not_to be_valid
        expect(user.errors[:cpf]).to include("can't be blank")
      end

      it "requires a unique cpf" do
        existing = create(:user)
        user.cpf = existing.cpf

        expect(user).not_to be_valid
        expect(user.errors[:cpf]).to include("has already been taken")
      end

      it "requires a valid cpf" do
        user.cpf = "12345678901"

        expect(user).not_to be_valid
        expect(user.errors[:cpf]).to include("is not a valid CPF")
      end
    end

    describe "name" do
      it "requires name" do
        user.name = nil

        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("can't be blank")
      end

      it "accepts international letters and common name punctuation" do
        %w[José\ Silva Mary-Jane\ O’Brien Jean-Luc\ Picard Anna\ M.\ Silva 李明].each do |name|
          user.name = name

          expect(user).to be_valid, "#{name.inspect} should be valid"
        end
      end

      it "rejects numbers and symbols" do
        [ "John3", "Mary@", "Bob_Smith", "Ana#", "123" ].each do |name|
          user.name = name

          expect(user).not_to be_valid, "#{name.inspect} should be invalid"
          expect(user.errors[:name]).to include("is invalid")
        end
      end
    end

    describe "password" do
      it "requires password" do
        user.password = nil
        user.password_confirmation = nil

        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it "requires password with at least 8 characters" do
        user.password = "short"
        user.password_confirmation = "short"

        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
      end
    end
  end

  describe "has_secure_password" do
    it "authenticates with the correct password" do
      user = create(:user, password: "password123", password_confirmation: "password123")

      expect(user.authenticate("password123")).to eq(user)
    end

    it "does not authenticate with an incorrect password" do
      user = create(:user, password: "password123", password_confirmation: "password123")

      expect(user.authenticate("wrongpassword")).to be_falsey
    end

    it "persists a password_digest" do
      user = create(:user)

      expect(user.password_digest).to be_present
    end
  end
end
