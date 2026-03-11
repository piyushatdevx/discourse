# frozen_string_literal: true

# name: user-language-switcher
# about: Allows guests and logged-in users to switch the Discourse UI language from the header
# version: 0.1.0
# authors: FanTribe
# url: https://example.com/user-language-switcher

enabled_site_setting :allow_user_locale

after_initialize do
  module ::UserLanguageSwitcher
    module LocaleResolver
      def with_resolved_locale(check_current_user: true)
        cookie_locale = request.cookies["user_locale"] || request.cookies["locale"]
        if cookie_locale.present? && LocaleSiteSetting.valid_value?(cookie_locale)
          candidates = [cookie_locale]

          I18n.ensure_all_loaded!
          candidates.each do |candidate|
            begin
              response.set_header("X-FT-Resolved-Locale", candidate)
              return I18n.with_locale(candidate) { yield }
            rescue I18n::InvalidLocale
              next
            end
          end

          fallback = SiteSettings::DefaultsProvider::DEFAULT_LOCALE
          response.set_header("X-FT-Resolved-Locale", fallback)
          return I18n.with_locale(fallback) { yield }
        end

        super
      end
    end

    module AnonymousLocaleOverride
      def anonymous_locale(request)
        cookie_locale = request.cookies["user_locale"] || request.cookies["locale"]
        if cookie_locale.present?
          return cookie_locale if LocaleSiteSetting.valid_value?(cookie_locale)
        end

        super
      end
    end
  end

  ApplicationController.prepend(::UserLanguageSwitcher::LocaleResolver)
  Discourse.singleton_class.prepend(::UserLanguageSwitcher::AnonymousLocaleOverride)

  Discourse::Application.routes.append { post "/user-language/set" => "user_language#set" }
end
