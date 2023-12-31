# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class VerificationCodeForm < Form
      mimic :sms_verification

      attribute :phone_number, Integer
      attribute :verification, String

      validates :verification, presence: true
    end
  end
end
