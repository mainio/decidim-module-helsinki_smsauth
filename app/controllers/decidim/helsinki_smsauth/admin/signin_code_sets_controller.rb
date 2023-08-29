# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Admin
      class SigninCodeSetsController < Decidim::Admin::ApplicationController
        def index
          enforce_permission_to :read, Decidim::HelsinkiSmsauth::SigninCodeSets.new
        end
      end
    end
  end
end
