# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class AccessCodeForm < Decidim::Form
      mimic :sms_verification

      attribute :access_code, String
      attribute :current_locale, String
      attribute :organization, Decidim::Organization

      validates :access_code, presence: true
    end
  end
end
