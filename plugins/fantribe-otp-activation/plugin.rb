# frozen_string_literal: true

# name: fantribe-otp-activation
# about: Replaces Discourse's link-based email activation with a 6-digit OTP
# version: 1.0.0
# authors: FanTribe
# url: https://github.com/piyushatdevx/discourse

enabled_site_setting :fantribe_signup_otp_enabled

require_relative "lib/fantribe_otp/otp_store"
require_relative "lib/fantribe_otp/email_activator_patch"

after_initialize do
  # Why not add_to_class:
  # add_to_class uses String#constantize → Object.const_get, which does NOT
  # trigger Zeitwerk autoloading. EmailActivator lives in app/services/user_activator.rb
  # which Zeitwerk hasn't lazy-loaded yet at after_initialize time in development,
  # so constantize raises NameError.
  #
  # We use prepend instead:
  # - require forces the file to load (no-op in production where eager-loading
  #   has already done it)
  # - prepend + super gives a clean fallback when the setting is disabled,
  #   without duplicating the original activate code
  # - In development, we re-apply the patch after each Zeitwerk reload so it
  #   isn't lost when EmailActivator's class object is replaced
  #
  # Failure mode: if Discourse renames EmailActivator in a future version,
  # the require raises LoadError and is rescued — the default link email is
  # sent and no exception is raised.
  service_file = Rails.root.join("app/services/user_activator.rb")

  begin
    require service_file.to_s
  rescue LoadError
    # user_activator.rb was renamed/moved in a future Discourse version.
    # Fall back to the default activation link email silently.
    next
  end

  EmailActivator.prepend(FantribeOtp::EmailActivatorPatch)

  # In development, Zeitwerk destroys and recreates EmailActivator on each
  # code reload. Re-apply the patch after each reload so it isn't lost.
  if Rails.env.development?
    ActiveSupport::Reloader.to_prepare do
      require service_file.to_s
      if EmailActivator.ancestors.exclude?(FantribeOtp::EmailActivatorPatch)
        EmailActivator.prepend(FantribeOtp::EmailActivatorPatch)
      end
    end
  end
end
