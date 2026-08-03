module AuthToken
  class Token
    class << self
      def encode(payload, exp: 15.minutes.from_now)
        JWT.encode(payload_with_expiration(payload, exp), secret, "HS256")
      end

      def decode(token)
        indifferent_access_hash(decoded_payload(token))
      rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
      end

      private

      def payload_with_expiration(payload, exp)
        payload.dup.merge(exp: exp.to_i)
      end

      def decoded_payload(token)
        JWT.decode(token, secret, true, algorithm: "HS256").first
      end

      def indifferent_access_hash(payload)
        ActiveSupport::HashWithIndifferentAccess.new(payload)
      end

      def secret
        ENV.fetch("JWT_SECRET", "")
      end
    end
  end
end
