# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class SigninCodeSetsController < Decidim::Admin::ApplicationController
          include Decidim::HelsinkiSmsauth::Verifications::Admin::Filterable

          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
          end

          private

          def collection
            @collection ||= Decidim::HelsinkiSmsauth::SigninCodeSet.all
          end

          def ideas
            @signin_code_sets ||= filtered_collection
          end
        end
      end
    end
  end
end
