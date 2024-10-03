# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      class AuthorizationsController < Decidim::Verifications::ApplicationController
        include Decidim::FormFactory
        include Decidim::Verifications::Renewable

        helper_method :authorization

        def new
          # We use the :update action here because this is also where the user
          # is redirected to in case they previously started the authorization
          # but did not finish it (i.e. the authorization is "pending").
          enforce_permission_to(:update, :authorization, authorization:)

          @form = form(AuthorizationForm).instance
        end

        def edit
          enforce_permission_to(:update, :authorization, authorization:)

          @form = ConfirmationForm.new
          verification_code
        end

        def create
          # We use the :update action here because this is also where the user
          # is redirected to in case they previously started the authorization
          # but did not finish it (i.e. the authorization is "pending").
          enforce_permission_to(:update, :authorization, authorization:)

          @form = AuthorizationForm.from_params(params.merge(user: current_user, school: nil, grade: nil, organization: current_organization))
          Decidim::Verifications::PerformAuthorizationStep.call(authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.sms")
              redirect_to redirect_smsauth
            end
            on(:invalid) do
              flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.sms")

              render :new
            end
          end
        end

        def resend_code
          return unless eligible_to?

          @form = AuthorizationForm.from_params(params.merge(user: current_user, organization: current_organization).merge(authorization_params))
          last_request_time = last_request
          Decidim::Verifications::PerformAuthorizationStep.call(authorization, @form) do
            on(:ok) do
              flash_message_for_resend(last_request_time)
              authorization_method = Decidim::Verifications::Adapter.from_element(authorization.name)
              redirect_to authorization_method.resume_authorization_path(redirect_url:)
            end
            on(:invalid) do
              flash.now[:alert] = I18n.t(".error", scope: "decidim.helsinki_smsauth.omniauth.sms.authenticate_user")
              render :edit
            end
          end
        end

        def school_info
          enforce_permission_to(:update, :authorization, authorization:)

          @form = form(::Decidim::HelsinkiSmsauth::SchoolMetadataForm).instance
        end

        def school_validation
          enforce_permission_to(:update, :authorization, authorization:)

          @form = form(::Decidim::HelsinkiSmsauth::SchoolMetadataForm).from_params(params)
          ValidateSchoolInfo.call(@form, authorization) do
            on(:ok) do
              handle_redirect
            end
          end
        end

        def update
          enforce_permission_to(:update, :authorization, authorization:)

          @form = ConfirmationForm.from_params(params)
          ConfirmUserPhoneAuthorization.call(authorization, @form, session) do
            on(:ok) do
              update_current_user!
              handle_redirect
            end
            on(:invalid) do
              flash[:error] = t("update.incorrect", scope: "decidim.helsinki_smsauth.verification.authorizations")
              redirect_to action: :edit
            end
            on(:expired) do
              redirect_to action: "resend_code", expired: true
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :authorization, authorization:)

          DestroyAuthorization.call(authorization) do
            on(:ok) do
              flash[:notice] = t("authorizations.destroy.success", scope: "decidim.verifications.sms")
              redirect_to action: :new
            end
          end
        end

        def access_code
          enforce_permission_to(:update, :authorization, authorization:)

          @form = form(::Decidim::HelsinkiSmsauth::AccessCodeForm).instance
        end

        def access_code_validation
          @form = form(::Decidim::HelsinkiSmsauth::AccessCodeForm).from_params(params.merge({ current_locale:, organization: current_organization }))
          ValidateAccessCode.call(@form, authorization, current_user) do
            on(:ok) do
              handle_redirect
            end

            on(:invalid) do
              flash[:error] = t("update.incorrect", scope: "decidim.helsinki_smsauth.verification.authorizations")
              redirect_to action: :access_code
            end
          end
        end

        private

        def authorization
          @authorization ||= Decidim::Authorization.find_or_initialize_by(
            user: current_user,
            name: "helsinki_smsauth_id"
          )
        end

        def update_current_user!
          current_user.update(authorization_params)
        end

        def authorization_params
          {
            phone_number: authorization.metadata["phone_number"]
          }
        end

        def verification_code
          @verification_code ||= authorization.verification_metadata["verification_code"]
        end

        def eligible_to?
          return true if ensure_sending_limit

          flash[:error] = I18n.t(".not_allowed", scope: "decidim.helsinki_smsauth.omniauth.send_message")
          redirect_to redirect_smsauth
          false
        end

        def ensure_sending_limit
          authorization.verification_metadata["code_sent_at"] < 1.minute.ago
        end

        def redirect_smsauth
          authorization_method = Decidim::Verifications::Adapter.from_element(authorization.name)
          authorization_method.resume_authorization_path(redirect_url:)
        end

        def handle_redirect
          if authorization.metadata["school"].nil?
            flash[:notice] = I18n.t(".school_info", scope: "decidim.helsinki_smsauth.verification.authorizations.school_info")
            redirect_to school_info_authorization_path
          else
            flash[:notice] = t("authorizations.update.success", scope: "decidim.verifications.sms")
            if redirect_url.blank?
              redirect_to decidim_verifications.authorizations_path
            else
              redirect_to stored_location_for(current_user)
            end
          end
        end

        def flash_message_for_resend(last_request)
          if long_ago?(last_request)
            flash[:alert] = I18n.t(".expired", scope: "decidim.helsinki_smsauth.omniauth.send_message")
          else
            flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.sms")
          end
        end

        def long_ago?(last_attempt)
          last_attempt <= 10.minutes.ago
        end

        def last_request
          authorization.verification_metadata["code_sent_at"]
        end
      end
    end
  end
end
