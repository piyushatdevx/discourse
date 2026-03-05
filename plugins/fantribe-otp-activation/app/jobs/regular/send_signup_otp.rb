# frozen_string_literal: true

module Jobs
  class SendSignupOtp < ::Jobs::Base
    def execute(args)
      user_id = args[:user_id].to_i
      email = args[:email].to_s
      email_token_str = args[:email_token].to_s

      return if user_id.zero? || email.blank? || email_token_str.blank?

      # 6-digit code in range 100_000..999_999
      otp_code = SecureRandom.random_number(900_000) + 100_000

      FantribeOtp::OtpStore.store(user_id, otp_code, email_token_str)

      FantribeOtpMailer.signup_otp(email, otp_code).deliver_now
    end
  end
end
