# frozen_string_literal: true

module FantribeOtp
  module EmailActivatorPatch
    def activate
      return super unless SiteSetting.fantribe_signup_otp_enabled

      email_token = user.email_tokens.create!(email: user.email, scope: EmailToken.scopes[:signup])
      Jobs.enqueue(
        :send_signup_otp,
        user_id: user.id,
        email: user.email,
        email_token: email_token.token,
      )
      success_message
    end
  end
end
