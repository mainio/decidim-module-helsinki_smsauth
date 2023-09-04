# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verification
      class ConfirmUserPhoneAuthorization < ::Decidim::Verifications::ConfirmUserAuthorization
        private

        def valid!
          reset_failed_attempts!
          broadcast(:ok)
        end
      end
    end
  end
end