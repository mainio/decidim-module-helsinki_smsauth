# frozen_string_literal: true

require "countries"
require "decidim/helsinki_smsauth/engine"
require_relative "helsinki_smsauth/authorization"
require_relative "helsinki_smsauth/verification"

module Decidim
  # This namespace holds the logic of the `Smsauth` component. This component
  # allows users to create smsauth in a participatory space.
  module HelsinkiSmsauth
    include ActiveSupport::Configurable

    autoload :PhoneNumberFormatter, "decidim/helsinki_smsauth/phone_number_formatter"

    # The country or countries to be selected in country selection
    # during sms verification/authentication. The default is being set to nil
    config_accessor :default_countries do
      nil
    end
  end
end
