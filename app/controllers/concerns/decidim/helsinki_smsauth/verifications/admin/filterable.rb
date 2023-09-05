# frozen_string_literal: true

module Decidim
  module HelsinkiSmsauth
    module Verifications
      module Admin
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            helper Decidim::Meetings::Admin::FilterableHelper

            private

            def base_query
              collection.order(start_time: :desc)
            end

            def filters
              [
                :generated_code_amount_lteq,
                :creator_present
              ]
            end

            def search_field_predicate
              :decidim_user_id
            end

            def filters_with_values
              {
                generated_code_amount_lteq: :used_code_amount
              }
            end
          end
        end
      end
    end
  end
end
