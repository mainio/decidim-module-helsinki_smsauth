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
        end
      end
    end
  end
end
