# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class SigninCodesController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def new
            @form = form(GenerateCodesForm).instance
          end

          def create
            @form = GenerateCodesForm.from_params(params.merge(user: current_user))
            ::Decidim::HelsinkiSmsauth::Verifications::Admin::GenerateAccessCodes.call(@form) do
              on(:ok) do |codes|
                generate_codes_session(codes)
                flash[:notice] = I18n.t(".success")
                redirect_to action: :view_generated_codes
              end
              on(:invalid) do
                flash[:error] = I18n.t(".error")
                render :new
              end
            end
          end

          def view_generated_codes
            # TOBE ADDED
          end

          private

          def generated_codes_session(codes)
            session[:generated_codes] = codes
          end
        end
      end
    end
  end
end
