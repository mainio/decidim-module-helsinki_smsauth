# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verification
      module AccessCode
        # This is an engine that authorizes users by sending them a code through
        # an SMS. Different from the core "sms" authorization method.
        class Engine < ::Rails::Engine
          isolate_namespace Decidim::HelsinkiSmsauth::Verification::AccessCode

          paths["db/migrate"] = nil
          paths["lib/tasks"] = nil

          routes do
            resource :authorizations, only: [:new, :create, :edit, :update, :destroy], as: :authorization do
              get :renew, on: :collection
            end

            root to: "authorizations#new"
          end

          initializer "decidim_helsinki_smsauth.access_code_verification_workflow", after: :load_config_initializers do |_app|
            Decidim::Verifications.register_workflow(:access_code) do |workflow|
              workflow.engine = Decidim::HelsinkiSmsauth::Verification::AccessCode::Engine
              workflow.admin_engine = Decidim::HelsinkiSmsauth::Verification::AccessCode::AdminEngine
            end
          end
        end
      end
    end
  end
end
