# frozen_string_literal: true

require "securerandom"
require "decidim/sms/twilio/gateway"

module Decidim
  module HelsinkiSmsauth
    module Verification
      class AuthorizationForm < Decidim::AuthorizationHandler
        attribute :phone_number, String
        attribute :school, String
        attribute :grade, String
        attribute :organization, Decidim::Organization

        validates :phone_number, :verification_code, :gateway, presence: true

        def handler_name
          "helsinki_smsauth_id"
        end

        # A mobile phone can only be verified once but it should be private.
        def unique_id
          Digest::MD5.hexdigest(
            "#{::Decidim::HelsinkiSmsauth.country_code[:country]}-#{phone_number}-#{Rails.application.secrets.secret_key_base}"
          )
        end

        # When there's a phone number, sanitize it allowing only numbers and +.
        def phone_number
          return unless super

          super.gsub(/[^0-9]/, "")
        end

        # The verification metadata to validate in the next step.
        def verification_metadata
          {
            verification_code: verification_code,
            code_sent_at: Time.current
          }
        end

        def metadata
          {
            phone_number: phone_number,
            school: school,
            grade: grade
          }
        end

        private

        def gateway
          @gateway ||=
            begin
              mobile_number = phone_with_country_code
              if Decidim.config.sms_gateway_service == "Decidim::Sms::Twilio::Gateway"
                Decidim.config.sms_gateway_service.constantize.new(mobile_number, generated_code, organization: organization)
              else
                Decidim.config.sms_gateway_service.constantize.new(mobile_number, generated_code)
              end
            end
        end

        def generated_code
          @generated_code ||= SecureRandom.random_number(1_000_000).to_s
        end

        def phone_with_country_code
          phone_formatter.format
        end

        def phone_formatter
          @phone_formatter ||= PhoneNumberFormatter.new(phone_number)
        end

        def verification_code
          return unless gateway
          return @verification_code if defined?(@verification_code)

          return unless gateway.deliver_code

          @verification_code = generated_code
        rescue Decidim::Sms::GatewayError => e
          @gateway_error_code = e.error_code
          errors.add(:base, sms_sending_error(@gateway_error_code))
        end

        def sms_sending_error(error_code)
          case error_code
          when :invalid_to_number
            I18n.t(".invalid_to_number", scope: "decidim.helsinki_smsauth.omniauth.sms.send_message.error")
          when :invalid_geo_permission
            I18n.t(".invalid_geo_permission", scope: "decidim.helsinki_smsauth.omniauth.sms.send_message.error")
          when :invalid_from_number
            I18n.t(".invalid_from_number", scope: "decidim.helsinki_smsauth.omniauth.sms.send_message.error")
          else
            I18n.t(".unknown", scope: "decidim.helsinki_smsauth.omniauth.sms.send_message.error")
          end
        end
      end
    end
  end
end
