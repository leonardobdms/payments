class AuthToken
  class << self
    def encode(payload, exp: 24.hours.from_now)
      payload = payload.dup
      payload[:exp] = exp.to_i
      JWT.encode(payload, private_key, "RS256")
    end

    def decode(token)
      body = JWT.decode(token, public_key, true, algorithm: "RS256")[0]
      ActiveSupport::HashWithIndifferentAccess.new(body)
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    private

    def private_key
      @private_key ||= rsa_from_env("JWT_PRIVATE_KEY") || fallback_keypair
    end

    def public_key
      @public_key ||= rsa_from_env("JWT_PUBLIC_KEY") || private_key.public_key
    end

    def rsa_from_env(name)
      pem = ENV[name].presence
      return if pem.blank?

      OpenSSL::PKey::RSA.new(pem.gsub("\\n", "\n"))
    end

    def fallback_keypair
      raise "JWT_PRIVATE_KEY and JWT_PUBLIC_KEY must be set" if Rails.env.production?

      @fallback_keypair ||= OpenSSL::PKey::RSA.generate(2048)
    end
  end
end
