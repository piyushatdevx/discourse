# frozen_string_literal: true

module FantribeOtp
  class OtpStore
    OTP_TTL = 600 # 10 minutes
    MAX_ATTEMPTS = 5

    # Atomic Lua script: increments the attempts counter inside the JSON payload
    # in a single Redis round-trip, preventing race conditions where two concurrent
    # wrong-code submissions both read attempts=4 and both think it's under the limit.
    INCREMENT_ATTEMPTS_LUA = DiscourseRedis::EvalHelper.new(<<~LUA) unless defined?(
        local raw = redis.call('GET', KEYS[1])
        if not raw then return nil end
        local data = cjson.decode(raw)
        data.attempts = data.attempts + 1
        local ttl = redis.call('TTL', KEYS[1])
        redis.call('SETEX', KEYS[1], math.max(ttl, 1), cjson.encode(data))
        return data.attempts
      LUA
      INCREMENT_ATTEMPTS_LUA
    )

    # Store a new OTP for the user. Overwrites any existing entry (resend path).
    # The plaintext email_token_string is stored so we can call EmailToken.confirm
    # at verification time — it's only available immediately after token creation.
    def self.store(user_id, otp_code, email_token_string)
      payload =
        JSON.generate(
          code_hash: Digest::SHA256.hexdigest(otp_code.to_s),
          email_token: email_token_string,
          attempts: 0,
        )
      Discourse.redis.setex(key(user_id), OTP_TTL, payload)
    end

    # Verify a submitted code against the stored entry.
    # Returns: :ok | :invalid | :expired | :locked
    def self.verify(user_id, submitted_code)
      raw = Discourse.redis.get(key(user_id))
      return :expired if raw.nil?

      data = JSON.parse(raw, symbolize_names: true)
      return :locked if data[:attempts] >= MAX_ATTEMPTS

      if Digest::SHA256.hexdigest(submitted_code.to_s) == data[:code_hash]
        :ok
      else
        INCREMENT_ATTEMPTS_LUA.eval(Discourse.redis, keys: [key(user_id)])
        :invalid
      end
    end

    # Returns the stored email_token string so the caller can confirm the account.
    def self.email_token_for(user_id)
      raw = Discourse.redis.get(key(user_id))
      return nil if raw.nil?
      JSON.parse(raw, symbolize_names: true)[:email_token]
    end

    def self.delete(user_id)
      Discourse.redis.del(key(user_id))
    end

    private

    def self.key(user_id)
      "otp:signup:#{user_id}"
    end
  end
end
