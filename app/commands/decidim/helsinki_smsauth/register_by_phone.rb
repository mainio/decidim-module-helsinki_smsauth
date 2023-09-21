# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class RegisterByPhone < Decidim::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) unless form.valid?

        result = update_or_create_user!
        broadcast(:ok, result)
      rescue ActiveRecord::RecordInvalid => e
        raise e
        broadcast(:error, e.record)
      end

      private

      attr_reader :form

      def update_or_create_user!
        return update_user! if form.user.present?

        create_user!
      end

      def create_user!
        generated_password = SecureRandom.hex
        Decidim::User.create! do |record|
          record.name = record_name
          record.nickname = UserBaseEntity.nicknamize(record_name)
          record.email = generate_email
          record.password = generated_password
          record.password_confirmation = generated_password

          record.skip_confirmation!

          record.phone_number = formatted_phone_number
          record.tos_agreement = "1"
          record.organization = form.organization
          record.newsletter_notifications_at = Time.current
          # record.accepted_tos_version = form.organization.tos_version
          record.locale = form.current_locale
        end
      end

      def update_user!
        return unless form.user

        form.user.update!(phone_number: formatted_phone_number)
        form.user
      end

      def generate_email
        EmailGenerator.new(form.organization, iso_country_name, form.phone_number).generate
      end

      def formatted_phone_number
        PhoneNumberFormatter.new(form.phone_number).format
      end

      def iso_country_name
        PhoneNumberFormatter.new(form.phone_number).iso_country_name
      end

      def record_name
        I18n.t("decidim.helsinki_smsauth.common.unnamed_user")
      end
    end
  end
end
