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
            create_code_session!
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
          Digest::MD5.hexdigest(
            "helsinki_smsauth_#{random_prefix}_#{form.access_code}"
          )
        end

        # Since we do not have anything uniquely identifiying users, we need
        # to provide a random prefix for the codes because the used codes are
        # destroyed from the database, so it is theoretically possible two
        # users would use the exact same code at some point.
        def random_prefix
          characters = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a
          64.times.map { characters.sample }.join
        end
      end
    end
  end
end
