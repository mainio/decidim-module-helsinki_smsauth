# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        module SigninCodesHelper
          def school_options
            ::Decidim::HelsinkiSmsauth::SchoolMetadata.school_options
          end
        end
      end
    end
  end
end
