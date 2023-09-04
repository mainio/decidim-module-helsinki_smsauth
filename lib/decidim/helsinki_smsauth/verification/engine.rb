# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verification
      # This is an engine that authorizes users by sending them a code through
      # an SMS. Different from the core "sms" authorization method.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::HelsinkiSmsauth::Verification

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :authorizations, only: [:new, :create, :edit, :update, :destroy], as: :authorization do
            get :resend_code, on: :collection
            get :renew, on: :collection
            get :access_code, on: :collection
            get :school_info
            post :school_validation
            get :access_code
          end

          root to: "authorizations#new"
        end

        initializer "decidim_helsinki_smsauth.verification_workflow", after: :load_config_initializers do |_app|
          next unless Decidim.sms_gateway_service

          Decidim::Verifications.register_workflow(:helsinki_smsauth_id) do |workflow|
            workflow.engine = Decidim::HelsinkiSmsauth::Verification::Engine
            workflow.admin_engine = Decidim::HelsinkiSmsauth::Verification::AdminEngine
          end
        end
      end
    end
  end
end
