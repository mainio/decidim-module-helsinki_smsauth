# frozen_string_literal: true

require "csv"
require "rubyXL"

require "decidim/helsinki_smsauth/engine"
require "decidim/helsinki_smsauth/admin"
require "decidim/helsinki_smsauth/admin_engine"
require_relative "helsinki_smsauth/authorization"
require_relative "helsinki_smsauth/verifications"
require_relative "helsinki_smsauth/mail_interceptors"

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

    # The auto email domain that is used for the generated account emails. If
    # this is not set, the organization host will be used and these emails will
    # not be intercepted.
    config_accessor :auto_email_domain do
      nil
    end

    # This configuration adds the validation period for the codes being generated
    # by the teachers. After this period of time since the generated code, the codes
    # would no longer be valid
    config_accessor :global_expiration_period do
      14
    end
  end
end
