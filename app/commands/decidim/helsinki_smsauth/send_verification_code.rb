# frozen_string_literal: true

require "decidim/sms/telia/gateway"

module Decidim
  module HelsinkiSmsauth
    # A command with all the business to add new line items to orders
    class SendVerificationCode < Decidim::Command
      def initialize(form, organization: nil)
        @form = form
        @organization = organization
      end

      # Sends the verification code on a valid form
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if @form.invalid?

        result = send_verification!
        unless result
          form.errors.add(:base, sms_sending_error(@gateway_error_code))
          return broadcast(:invalid)
        end

        broadcast(:ok, result, @gateway_error_code)
      end

      private

      attr_reader :form, :organization

      def send_verification!
        gateway.deliver_code

        gateway.code
      rescue Decidim::Sms::GatewayError => e
        @gateway_error_code = e.error_code

        # This is the special case, where we want to inform the user that
        # their message has been queued because of the server busy
        return gateway.code if @gateway_error_code == :server_busy

        false
      end

      def sms_sending_error(error_code)
        case error_code
        when :invalid_to_number
          I18n.t(".invalid_to_number", scope: "decidim.helsinki_smsauth.omniauth.send_message.error")
        when :destination_whitelist
          I18n.t(".destination_whitelist", scope: "decidim.helsinki_smsauth.omniauth.send_message.error")
        when :destination_blacklist
          I18n.t(".destination_blacklist", scope: "decidim.helsinki_smsauth.omniauth.send_message.error")
        when :server_error
          I18n.t(".server_error", scope: "decidim.helsinki_smsauth.omniauth.send_message.error")
        else
          I18n.t(".unknown", scope: "decidim.helsinki_smsauth.omniauth.send_message.error")
        end
      end

      def gateway
        @gateway ||=
          begin
            phone_number = phone_with_country_code(form.phone_number)
            code = generate_code
            gateway = Decidim.config.sms_gateway_service.constantize
            if gateway.instance_method(:initialize).parameters.length > 2
              gateway.new(phone_number, code, organization:)
            else
              gateway.new(phone_number, code)
            end
          end
      end

      def generate_code
        code = SecureRandom.random_number(10**auth_code_length).to_s
        add_zeros(code)
      end

      def auth_code_length
        @auth_code_length ||= 7
      end

      def phone_with_country_code(phone_number)
        PhoneNumberFormatter.new(phone_number).format
      end

      def add_zeros(code)
        return code if code.length == auth_code_length

        ("0" * (auth_code_length - code.length)) + code
      end
    end
  end
end
