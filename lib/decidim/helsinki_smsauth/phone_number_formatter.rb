# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class PhoneNumberFormatter
      def initialize(phone_number, show_country: true)
        @phone_number = phone_number
        @show_country = show_country
      end

      def format
        "#{country_code_prefix}#{phone_number}"
      end

      def format_human(show_country: true)
        if show_country
          "#{country_code_prefix} #{phone_number_parts.join(" ")}"
        else
          "0#{phone_number_parts.join(" ")}"
        end
      end

      def iso_country_name
        country_code_hash[:country]
      end

      def country_code_prefix
        country_code_hash[:code]
      end

      private

      attr_reader :phone_number, :show_country

      def phone_number_parts
        @phone_number_parts ||= [].tap do |parts|
          number = phone_number.to_s
          parts << number[0..1]
          parts << number[2..4]
          parts << number[5..-1]
        end
      end

      def country_code_hash
        @country_code_hash ||= ::Decidim::HelsinkiSmsauth.country_code
      end
    end
  end
end
