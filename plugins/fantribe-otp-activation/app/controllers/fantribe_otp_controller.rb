# frozen_string_literal: true

class FantribeOtpController < ApplicationController
  requires_plugin "fantribe-otp-activation"

  include CurrentUser

  # These actions are called by unauthenticated users (they haven't confirmed
  # their email yet), so we must skip the login-redirect guards.
  skip_before_action :check_xhr
  skip_before_action :redirect_to_login_if_required
  skip_before_action :redirect_to_profile_if_required

  # POST /u/confirm-signup-otp
  # Verifies the submitted 6-digit code, confirms the EmailToken, activates
  # the user, and logs them in — replicating what perform_account_activation
  # does for link-based activation.
  def confirm
    params.require(%i[email code])

    email = params[:email].to_s.strip.downcase
    code = params[:code].to_s.strip

    user = User.find_by_email(email)
    # Return the same generic error whether the user exists or not to avoid
    # leaking account existence through timing/message differences.
    return render_json_error(I18n.t("fantribe_otp.errors.invalid_code"), status: 422) if user.nil?

    case FantribeOtp::OtpStore.verify(user.id, code)
    when :expired
      return render_json_error(I18n.t("fantribe_otp.errors.expired"), status: 422)
    when :locked
      return render_json_error(I18n.t("fantribe_otp.errors.locked"), status: 429)
    when :invalid
      return render_json_error(I18n.t("fantribe_otp.errors.invalid_code"), status: 422)
    end

    # Retrieve the email_token string stored at OTP generation time, then
    # confirm it. EmailToken.confirm handles everything: setting user.active,
    # welcome message flag, invite redemption, and group auto-assignment.
    token_str = FantribeOtp::OtpStore.email_token_for(user.id)
    activated_user = EmailToken.confirm(token_str, scope: EmailToken.scopes[:signup])

    # Always delete the OTP after one successful verification.
    FantribeOtp::OtpStore.delete(user.id)

    if activated_user.nil?
      # Token was already confirmed (e.g. user clicked the backup link email).
      # Treat the account as already active and proceed.
      activated_user = user.reload
      unless activated_user.active?
        return render_json_error(I18n.t("fantribe_otp.errors.already_confirmed"), status: 422)
      end
    end

    if Guardian.new(activated_user).can_access_forum?
      activated_user.enqueue_welcome_message("welcome_user") if activated_user.send_welcome_message
      log_on_user(activated_user)
      render json: success_json.merge(redirect_to: "/")
    else
      render json: success_json.merge(needs_approval: true)
    end
  end

  # POST /u/resend-signup-otp
  # Regenerates the OTP and re-sends the email.
  # Rate-limited to 3 resends per 10 minutes per user (using Discourse's built-in
  # RateLimiter so it integrates cleanly with the existing Redis rate-limit namespace).
  def resend
    params.require(:email)

    email = params[:email].to_s.strip.downcase
    user = User.find_by_email(email)

    # Always return success — don't reveal whether the email is registered.
    return render json: success_json if user.nil? || user.active?

    RateLimiter.new(user, "signup-otp-resend", 3, 10.minutes).performed!

    email_token = user.email_tokens.create!(email: user.email, scope: EmailToken.scopes[:signup])
    Jobs.enqueue(
      :send_signup_otp,
      user_id: user.id,
      email: user.email,
      email_token: email_token.token,
    )

    render json: success_json
  rescue RateLimiter::LimitExceeded
    render_json_error(I18n.t("fantribe_otp.errors.resend_limit"), status: 429)
  end
end
