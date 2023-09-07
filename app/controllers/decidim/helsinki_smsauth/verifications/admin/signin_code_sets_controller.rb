# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        class SigninCodeSetsController < Decidim::Admin::ApplicationController
          include Decidim::HelsinkiSmsauth::Verifications::Admin::Filterable
          helper_method :school_name
          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization
            @collection
          end

          private

          def collection
            @collection ||= Decidim::HelsinkiSmsauth::SigninCodeSet.all
          end

          def school_name(school_code)
            ::Decidim::HelsinkiSmsauth::SchoolMetadata.school_name(school_code)
          end
        end
      end
    end
  end
end
