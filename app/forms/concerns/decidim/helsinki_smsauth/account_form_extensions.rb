# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module AccountFormExtensions
      extend ActiveSupport::Concern

      included do
        validates :email, presence: true, "valid_email_2/email": { disposable: true }
        # validates :email, "valid_email_2/email": { disposable: true }, if: :not_development
        attribute :phone_number, String

        def mask_number
          return if phone_number.blank?

          formatted = phone_instance.format

          "#{phone_instance.country_code_prefix}*****#{formatted[-3..-1]}"
        end

        private

        def phone_instance
          return if phone_number.blank?

          Decidim::HelsinkiSmsauth::PhoneNumberFormatter.new(phone_number)
        end

        def not_development
          !Rails.env.development?
        end
      end
    end
  end
end
