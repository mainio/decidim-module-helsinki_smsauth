# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    # This is the engine that runs on the public interface of `helsinki_smsauth`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::HelsinkiSmsauth::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        scope "/organization" do
          resources :auth_settings, param: :slug, only: [:edit, :update], path: ""
        end
      end

      initializer "decidim_helsinki_smsauth.mount_routes", before: "decidim_admin.mount_routes" do
        Decidim::Admin::Engine.routes.append do
          mount Decidim::HelsinkiSmsauth::AdminEngine => "/"
        end
      end

      initializer "decidim_helsinki_smsauth.add_half_signup_menu_to_admin", before: "decidim_admin.admin_settings_menu" do
        Decidim.menu :admin_settings_menu do |menu|
          # /organization/
          menu.add_item :edit_organization,
                        I18n.t("menu.auth_settings", scope: "decidim.helsinki_smsauth"),
                        decidim_helsinki_smsauth.edit_auth_setting_path(slug: "authentication_settings"),
                        position: 1.1,
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active: is_active_link?(decidim_helsinki_smsauth.edit_auth_setting_path(
                                                  slug: "authentication_settings"
                                                ))
        end
      end

      def load_seed
        nil
      end
    end
  end
end
