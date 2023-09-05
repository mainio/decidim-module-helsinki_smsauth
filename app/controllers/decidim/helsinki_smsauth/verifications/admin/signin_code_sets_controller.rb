# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class SigninCodeSetsController < Decidim::Admin::ApplicationController
          def index
            enforce_permission_to :index, :authorization
          end
        end
      end
    end
  end
end
