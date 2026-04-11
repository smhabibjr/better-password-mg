module JsonWebToken
    SECRET_KEY = Rails.application.credentials.dig(:secret_key_base)

    def self.encode(payload, exp = 2.minutes.from_now.to_i)
        payload[:exp] = exp
        JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
        decoded = JWT.decode(token, SECRET_KEY).first
        HashWithIndifferentAccess.new decoded
    end

end