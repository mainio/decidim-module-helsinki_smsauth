# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class SigninCodeSetsController < Decidim::Admin::ApplicationController
          include Decidim::HelsinkiSmsauth::Verifications::Admin::Filterable
          layout "decidim/admin/users"

          helper_method :sets

          def index
            enforce_permission_to :index, :authorization
            @collection = paginate(collection)
          end

          private

          def sets
            @sets ||= filtered_collection
          end

          def collection
            @collection = ::Decidim::HelsinkiSmsauth::SigninCodeSet.all
            return filtered_collection.where("generated_code_amount < 0") if ransack_params[:generated_code_amount_not_eq].present?

            @collection
          end
        end
      end
    end
  end
end
