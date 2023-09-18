# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    class SigninCode < ApplicationRecord
      belongs_to :signin_code_set, foreign_key: "decidim_signin_code_set_id", class_name: "::Decidim::HelsinkiSmsauth::SigninCodeSet"

      validates :code_hash, uniqueness: true, if: -> { code_hash.present? }
      before_save :generate!
      after_destroy :increment_used_codes

      # generate method should be public, since it should be accessible by GenerateAccessCode
      # class, to be able to retrieve the codes being generated. Otherwise, after generating the
      # code, we can not retrieve the random code to be shown to the user.
      def generate!
        return if code_hash.present?

        loop do
          digest = "#{generated_code}-#{Rails.application.secrets.secret_key_base}"
          self.code_hash = Digest::MD5.hexdigest(digest)
          return generated_code if ::Decidim::HelsinkiSmsauth::SigninCode.find_by(code_hash: code_hash).blank?
        end
      end

      private

      def generated_code(code_length = 10)
        characters = ("0".."9").to_a + ("A".."Z").to_a
        characters.sample(code_length).join
      end

      def increment_used_codes
        signin_code_set.increment(:used_code_amount)
        signin_code_set.save!
      end
    end
  end
end
