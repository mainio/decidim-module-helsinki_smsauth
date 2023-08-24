# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    # Abstract class from which all models in this engine inherit.
    class EmailGenerator
      include Decidim::Sms::Twilio::TokenGenerator

      def initialize(organization, phone_country, phone_number)
        @organization = organization
        @phone_country = phone_country
        @phone_number = phone_number
      end

      def generate
        "helsinki_smsauth-#{generate_token(token_data)}@#{organization.host}"
      end

      private

      attr_reader :organization, :phone_country, :phone_number

      def token_data
        "#{phone_country}-#{phone_number}"
      end
    end
  end
end
