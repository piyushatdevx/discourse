# frozen_string_literal: true

class UserLanguageController < ApplicationController
  requires_plugin "user-language-switcher"

  EXTRA_LOCALES = %w[hi hi_in].freeze

  def set
    locale = params[:locale].to_s.strip
    normalized = locale.downcase
    locale = "hi_IN" if %w[hi hi_in].include?(normalized)

    unless valid_locale?(locale)
      return(
        render json: {
                 error: I18n.t("user_language_switcher.invalid_locale", locale: locale),
               },
               status: :unprocessable_entity
      )
    end

    cookie_args = { value: locale, expires: 1.year.from_now, httponly: false, same_site: "Lax" }
    cookie_args[:path] = Discourse.base_path if Discourse.base_path.present?

    cookies[:user_locale] = cookie_args
    cookies[:locale] = cookie_args

    if current_user
      begin
        current_user.update!(locale: locale)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
        # Allow plugin-managed locales even when core locale validations are stricter.
        current_user.update_columns(locale: locale)
      end
    end

    render json: { success: true, locale: locale }
  end

  private

  def valid_locale?(locale)
    normalized = locale.to_s.downcase
    LocaleSiteSetting.valid_value?(locale) || EXTRA_LOCALES.include?(normalized)
  end
end
