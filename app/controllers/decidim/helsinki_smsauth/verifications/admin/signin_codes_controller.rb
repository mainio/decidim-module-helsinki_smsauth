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
                flash[:notice] = t(".success")
                redirect_to action: :view_generated_codes
              end
              on(:invalid) do
                flash[:error] = t(".error")
                render :new
              end
            end
          end

          def view_generated_codes
            @codes = generated_codes_session
            remove_generated_codes_session
          end

          private

          def generate_codes_session(codes)
            session[:generated_codes] = codes
          end

          def generated_codes_session
            session[:generated_codes]
          end

          def remove_generated_codes_session
            session&.delete(:generated_codes)
          end
        end
      end
    end
  end
end
