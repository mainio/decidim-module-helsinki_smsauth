# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verification
      module Admin
        class SigninCodeSetsController < Decidim::Admin::ApplicationController
          def index
            enforce_permission_to :read, :signin_code_sets
          end
        end
      end
    end
  end
end
