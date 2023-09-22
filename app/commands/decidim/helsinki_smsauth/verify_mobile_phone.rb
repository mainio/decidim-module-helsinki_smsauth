# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    # A command with all the business to add new line items to orders
    class VerifyMobilePhone < Decidim::Command
      def initialize(form, data)
        @form = form
        @data = data.presence.transform_keys(&:to_sym) || {}
      end

      def call
        return broadcast(:invalid) if @form.invalid?
        return broadcast(:invalid) unless validate!(@form.verification)
        return broadcast(:expired) unless code_still_valid?

        broadcast(:ok)
      end

      private

      attr_accessor :data, :user

      def validate!(provided_code)
        verification_code == provided_code
      end

      def code_still_valid?
        verification_code_sent_at && verification_code_sent_at > 10.minutes.ago
      end

      def verification_code
        @verification_code ||= data[:verification_code]
      end

      def verification_code_sent_at
        @verification_code_sent_at ||= data[:sent_at]&.in_time_zone
      end
    end
  end
end
