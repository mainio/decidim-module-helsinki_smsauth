# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class PhoneNumberFormatter
      def initialize(phone_number)
        @phone_number = phone_number
      end

      def format
        "#{country_code_prefix}#{phone_number}"
      end

      def iso_country_name
        country_code_hash[:country]
      end

      def country_code_prefix
        country_code_hash[:code]
      end
      private

      attr_reader :phone_number

      def country_code_hash
        @country_code_hash ||= ::Decidim::HelsinkiSmsauth.country_code
      end
    end
  end
end
