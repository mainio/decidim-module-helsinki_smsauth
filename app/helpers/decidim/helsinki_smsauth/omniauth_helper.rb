# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    # Helpers for the omniauth views.
    module OmniauthHelper
      def current_phone_number
        PhoneNumberFormatter.new(session[:authentication_attempt]["phone"]).format_human(show_country: false)
      end
    end
  end
end
