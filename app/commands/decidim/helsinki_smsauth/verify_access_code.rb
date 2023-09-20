# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class VerifyAccessCode < Decidim::Command
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if @form.invalid?
        return broadcast(:invalid) unless validate!

        transaction do
          destroy_access_code!
          create_user!
          create_code_session!
        end
        broadcast(:ok, @user, code_set_hash)
      end

      private

      attr_reader :form

      def access_code
        @access_code ||= access_code_instance(form.access_code)
      end

      def validate!
        access_code.present?
      end

      def create_user!
        generated_password = SecureRandom.hex
        @user = Decidim::User.create! do |record|
          record.name = record_name
          record.nickname = UserBaseEntity.nicknamize(record_name)
          record.email = generate_email
          record.password = generated_password
          record.password_confirmation = generated_password

          record.skip_confirmation!

          record.tos_agreement = "1"
          record.organization = form.organization
          record.newsletter_notifications_at = Time.current
          record.accepted_tos_version = form.organization.tos_version
          record.locale = form.current_locale
        end
      end

      def record_name
        I18n.t("decidim.helsinki_smsauth.common.unnamed_user")
      end

      def generate_email
        "helsinkisms-#{generate_token("#{prefix}_#{form.access_code}")}@#{email_domain}"
      end

      def email_domain
        Decidim::HelsinkiSmsauth.auto_email_domain || form.organization.host
      end

      def generate_token(payload)
        Digest::MD5.hexdigest(
          [
            payload.to_s,
            Rails.application.secrets.secret_key_base
          ].join(":")
        )
      end

      def prefix
        characters = ("0".."9").to_a + ("A".."Z").to_a
        characters.sample(10).join
      end

      def access_code_instance(code)
        digest = "#{code}-#{Rails.application.secrets.secret_key_base}"
        code_hash = Digest::MD5.hexdigest(digest)
        ::Decidim::HelsinkiSmsauth::SigninCode.find_by(code_hash: code_hash)
      end

      def destroy_access_code!
        access_code.destroy
      end

      def create_code_session!
        ::Decidim::HelsinkiSmsauth::SigninCodeSession.create!(
          user: @user,
          signin_code_set: access_code.signin_code_set
        )
      end

      def code_set_hash
        access_code.signin_code_set.metadata
      end
    end
  end
end
