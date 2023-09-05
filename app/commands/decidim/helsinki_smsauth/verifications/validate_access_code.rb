# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      class ValidateAccessCode < ::Decidim::HelsinkiSmsauth::VerifyAccessCode
        def initialize(form, authorization, user)
          @form = form
          @authorization = authorization
          @user = user
        end

        def call
          return broadcast(:invalid) if @form.invalid?
          return broadcast(:invalid) unless validate!

          transaction do
            destroy_access_code!
            update_authorization!
            create_code_seesion!
          end
          broadcast(:ok)
        end

        private

        attr_reader :form, :authorization

        def update_authorization!
          authorization.metadata = {
            grade: code_set_hash["grade"],
            school: code_set_hash["school"],
            phone_number: nil
          }
          authorization.unique_id = unique_id
          authorization.grant!
        end

        def unique_id
          "helsinki_smsauth_#{prefix}_#{form.access_code}"
        end

        def prefix
          characters = ("0".."9").to_a + ("A".."Z").to_a
          characters.sample(10).join
        end
      end
    end
  end
end
