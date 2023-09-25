# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class PhoneNumberFormatter
      def initialize(phone_number, show_country: true)
        @phone_number = phone_number
        @show_country = show_country
      end

      def format
        "#{country_code_prefix}#{refined_phone_number}"
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

      def refined_phone_number(phone_number)
        country_prefix = country_code_prefix.split("+").last
        entry = phone_number.to_s
        if entry.start_with?("00")
          refined_phone_number(entry.gsub(/\A00/, ""))
        elsif entry.start_with?("+")
          refined_phone_number(entry.gsub(/\A\+/, ""))
        elsif entry.start_with?("0")
          entry.gsub(/\A0/, "")
        elsif entry.match?(/\A#{country_prefix}/)
          refined_phone_number(entry.gsub(/\A#{country_prefix}/, ""))
        else
          entry
        end
      end
    end
  end
end
