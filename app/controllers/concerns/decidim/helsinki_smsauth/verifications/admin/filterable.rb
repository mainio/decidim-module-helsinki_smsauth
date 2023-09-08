# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            private

            def base_query
              collection
            end

            def filters
              [
                :has_unused_codes_eq
              ]
            end

            def search_field_predicate
              :creator_name_cont
            end

            def filters_with_values
              {
                has_unused_codes_eq: [true, false]
              }
            end
          end
        end
      end
    end
  end
end
