module AuthToken
  class Refresh
    def initialize(token: nil, user: nil)
      @token = token
      @user = user
    end

    def issue
      {
        access_token: Token.encode({ user_id: user.id }),
        refresh_token: create_refresh_token!
      }
    end

    def refresh!
      return unless refresh_token&.active?
      return unless token_belongs_to_user?

      refresh_token.revoke!

      self.class.new(user:).issue
    end

    def revoke!
      return false if refresh_token.blank?
      return false unless token_belongs_to_user?

      refresh_token.revoke!
      true
    end

    private

    attr_reader :token

    def user
      @user ||= refresh_token&.user
    end

    def refresh_token
      @refresh_token ||= ::RefreshToken.find_by(token_digest: digest(token)) if token.present?
    end

    def token_belongs_to_user?
      @user.nil? || refresh_token.user_id == @user.id
    end

    def create_refresh_token!
      user.refresh_tokens.create!(
        token_digest: digest(new_refresh_token),
        expires_at: 30.days.from_now
      )

      new_refresh_token
    end

    def digest(value)
      Digest::SHA256.hexdigest(value)
    end

    def new_refresh_token
      @new_refresh_token ||= SecureRandom.urlsafe_base64(32)
    end
  end
end
