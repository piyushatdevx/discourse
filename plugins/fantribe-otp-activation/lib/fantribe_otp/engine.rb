# frozen_string_literal: true

module FantribeOtp
  class Engine < ::Rails::Engine
    engine_name "fantribe-otp-activation"
    # No isolate_namespace — controller, jobs, and mailer live at top level.
    # The engine's sole purpose is to register app/* with Rails' Zeitwerk
    # autoloader so FantribeOtpController, Jobs::SendSignupOtp, and
    # FantribeOtpMailer can be constantized at runtime.
  end
end
