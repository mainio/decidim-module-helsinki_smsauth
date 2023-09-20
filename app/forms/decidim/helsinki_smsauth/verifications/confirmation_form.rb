# frozen_string_literal: true

require "securerandom"

module Decidim
  module HelsinkiSmsauth
    module Verifications
      class ConfirmationForm < AuthorizationHandler
        mimic :sms_authorization_confirmation

        attribute :verification_code, String

        validates :verification_code, presence: true

        def verification_metadata
          { "verification_code" => verification_code }
        end
      end
    end
  end
end
