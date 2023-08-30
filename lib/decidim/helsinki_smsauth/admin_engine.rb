# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    # This is the engine that runs on the public interface of `helsinki_smsauth`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::HelsinkiSmsauth::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        scope "/access_codes" do
          resources :signin_code_sets, only: [:index], path: ""
        end
      end

      initializer "decidim_helsinki_smsauth.mount_routes", before: "decidim_admin.mount_routes" do
        Decidim::Admin::Engine.routes.append do
          mount Decidim::HelsinkiSmsauth::AdminEngine => "/"
        end
      end

      initializer "decidim_helsinki_smsauth.add_helsinki_signin_codes_to_admin", after: "decidim_admin.admin_user_menu" do
        Decidim.menu :admin_user_menu do |menu|
          # /admin/
          menu.add_item :access_codes,
                        I18n.t("menu.access_codes", scope: "decidim.helsinki_smsauth"),
                        decidim_helsinki_smsauth_admin.signin_code_sets_path,
                        if: allowed_to?(:index, :officialization),
                        position: 6,
                        active: is_active_link?(decidim_helsinki_smsauth_admin.signin_code_sets_path)
        end
      end
    end
  end
end
