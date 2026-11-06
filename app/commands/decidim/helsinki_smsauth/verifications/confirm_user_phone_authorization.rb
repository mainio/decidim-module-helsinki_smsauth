# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      class ConfirmUserPhoneAuthorization < ::Decidim::Verifications::ConfirmUserAuthorization
        def call
          return already_confirmed! if authorization.granted?

          Decidim::Authorization.transaction do
            authorization.lock!
            authorization.clear_expired_lock!

            return locked! if authorization.locked_for_confirmation?

            return invalid! unless form.valid?

            if confirmation_successful?
              if code_still_valid?
                valid!
              else
                expire!
              end
            else
              invalid!
            end
          end
        rescue StandardError => e
          Rails.logger.debug e
          invalid!(e.message)
        end

        private

        def valid!
          authorization.reset_failed_attempts!
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
