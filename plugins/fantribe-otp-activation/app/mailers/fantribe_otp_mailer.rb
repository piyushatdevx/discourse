# frozen_string_literal: true

class FantribeOtpMailer < ActionMailer::Base
  include Email::BuildEmailHelper

  def signup_otp(to_address, otp_code)
    build_email(
      to_address,
      template: "fantribe_otp_mailer.signup_otp",
      site_title: SiteSetting.title,
      code: otp_code,
    )
  end
end
