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
    end
  end
end
