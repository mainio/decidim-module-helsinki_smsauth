# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module HelsinkiSmsauth
    # This is the engine that runs on the public interface of helsinki_smsauth.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::HelsinkiSmsauth

      routes do
        devise_scope :user do
          # We need to define the routes to be able to show the sign in views
          # within Decidim.
          match(
            "/users/auth/sms",
            to: "omniauth#new",
            via: [:get, :post]
          )

          namespace :users_auth_sms, path: "/users/auth/sms", module: "omniauth" do
            get :edit
            post :update
            post :send_message
            get :resend_code
            get :verification
            post :authenticate_user
            get :school_info
            post :user_registry
            get :access_code
            post :access_code_validation
          end
        end
      end

      initializer "decidim_helsinki_smsauth.mount_routes", before: :add_routing_paths do
        # Mount the engine routes to Decidim::Core::Engine because otherwise
        # they would not get mounted properly. Note also that we need to prepend
        # the routes in order for them to override Decidim's own routes for the
        # "sms" authentication.
        Decidim::Core::Engine.routes.prepend do
          mount Decidim::HelsinkiSmsauth::Engine => "/"
        end
      end

      initializer "decidim_helsinki_smsauth.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_helsinki_smsauth.overrides" do |app|
        app.config.to_prepare do
          Decidim::User.include(Decidim::HelsinkiSmsauth::SmsConfirmableUser)
          # commands
          Decidim::DestroyAccount.include(
            Decidim::HelsinkiSmsauth::DestroyAccountOverrides
          )
          Decidim::Verifications::ConfirmUserAuthorization.include(
            Decidim::HelsinkiSmsauth::ConfirmUserAuthorizationExtensions
          )
          # forms
          Decidim::AccountForm.include(Decidim::HelsinkiSmsauth::AccountFormExtensions)
        end
      end

      # This initializer is only for the tests so that we do not need to modify
      # the secrets and configuration of the application.
      if Rails.env.test?
        initializer "decidim_helsinki_smsauth.tests", before: :add_routing_paths do
          Rails.application.secrets[:omniauth][:sms] = { enabled: true, icon: "phone" }
        end
      end
    end
  end
end
