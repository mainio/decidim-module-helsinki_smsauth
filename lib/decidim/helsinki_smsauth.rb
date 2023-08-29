# frozen_string_literal: true

require "decidim/helsinki_smsauth/engine"
require "decidim/helsinki_smsauth/admin"
require "decidim/helsinki_smsauth/admin_engine"
require_relative "helsinki_smsauth/authorization"
require_relative "helsinki_smsauth/verification"
require "decidim/sms/twilio"

module Decidim
  # This namespace holds the logic of the `Smsauth` component. This component
  # allows users to create smsauth in a participatory space.
  module HelsinkiSmsauth
    include ActiveSupport::Configurable

    autoload :SchoolMetadata, "decidim/helsinki_smsauth/school_metadata"
    autoload :PhoneNumberFormatter, "decidim/helsinki_smsauth/phone_number_formatter"

    # The country name is neeeded for generating the unique id and the countey code
    # is the country code being used for sending sms
    config_accessor :country_code do
      { country: "FI", code: "+358" }
    end
  end
end
