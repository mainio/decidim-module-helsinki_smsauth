# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      # This is an engine that implements the administration interface for
      # user authorization by postal letter code.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::HelsinkiSmsauth::Verifications::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resources :signin_code_sets, only: :index
          resources :signin_codes, only: [:new, :create]

          get :view_generated_codes

          root to: "signin_code_sets#index"
        end
      end
    end
  end
end
