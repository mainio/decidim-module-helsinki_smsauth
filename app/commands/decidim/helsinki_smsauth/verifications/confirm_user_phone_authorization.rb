# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      class ConfirmUserPhoneAuthorization < ::Decidim::Verifications::ConfirmUserAuthorization
        def call
          return already_confirmed! if authorization.granted?

          return invalid! unless form.valid?

          throttle! if too_many_failed_attempts?
          if confirmation_successful?
            if code_still_valid?
              valid!
            else
              expire!
            end
          else
            invalid!
          end
        rescue StandardError => e
          Rails.logger.debug e
          invalid!(e.message)
        end

        private

        def valid!
          reset_failed_attempts!
          broadcast(:ok)
        end

        def code_still_valid?
          authorization.verification_metadata["code_sent_at"].in_time_zone >= 10.minutes.ago
        end

        def expire!
          broadcast(:expired)
        end
      end
    end
  end
end
