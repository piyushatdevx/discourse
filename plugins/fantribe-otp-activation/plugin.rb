# frozen_string_literal: true

# name: fantribe-otp-activation
# about: Replaces Discourse's link-based email activation with a 6-digit OTP
# version: 1.0.0
# authors: FanTribe
# url: https://github.com/piyushatdevx/discourse

enabled_site_setting :fantribe_signup_otp_enabled

require_relative "lib/fantribe_otp/otp_store"

after_initialize do
  # Patch EmailActivator#activate to intercept the signup flow.
  #
  # When fantribe_signup_otp_enabled is ON:
  #   - Creates the email_token record (still needed to confirm the account later)
  #   - Stores the plaintext token in Redis alongside the OTP so we can call
  #     EmailToken.confirm at verification time
  #   - Enqueues SendSignupOtp instead of the default link email
  #
  # When OFF: falls back to the default Discourse activation link email.
  #
  # Failure mode: if Discourse renames EmailActivator in a future version this
  # add_to_class call is silently ignored and the default link email is sent.
  add_to_class("EmailActivator", "activate") do
    email_token = user.email_tokens.create!(email: user.email, scope: EmailToken.scopes[:signup])

    if SiteSetting.fantribe_signup_otp_enabled
      Jobs.enqueue(
        :send_signup_otp,
        user_id: user.id,
        email: user.email,
        email_token: email_token.token,
      )
    else
      EmailToken.enqueue_signup_email(email_token)
    end

    success_message
  end
end
