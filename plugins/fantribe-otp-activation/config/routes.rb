# frozen_string_literal: true

Discourse::Application.routes.draw do
  post "/u/confirm-signup-otp" => "fantribe_otp#confirm"
  post "/u/resend-signup-otp" => "fantribe_otp#resend"
end
