# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class RegisterByPhone < Decidim::Command
      include Decidim::Sms::Twilio::TokenGenerator

      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) unless form.valid?

        user = create_user!
        broadcast(:ok, user)
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:error, e.record)
      end

      private

      attr_reader :form

      def create_user!
        generated_password = SecureRandom.hex
        Decidim::User.create! do |record|
          record.name = record_name
          record.nickname = UserBaseEntity.nicknamize(record_name)
          record.email = generate_email
          record.password = generated_password
          record.password_confirmation = generated_password

          record.skip_confirmation!

          record.phone_number = form.phone_number
          record.tos_agreement = "1"
          record.organization = form.organization
          record.newsletter_notifications_at = Time.current
          record.accepted_tos_version = form.organization.tos_version
          record.locale = form.current_locale
        end
      end

      def generate_email
        EmailGenerator.new(form.organization, iso_country_name, form.phone_number).generate
      end

      def iso_country_name
        PhoneNumberFormatter.new(form.phone_number).iso_country_name
      end

      def record_name
        "helsinki_smsauth_unnamed_user"
      end
    end
  end
end
