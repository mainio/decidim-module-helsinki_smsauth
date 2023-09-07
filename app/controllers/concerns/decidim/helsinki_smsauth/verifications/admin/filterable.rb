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
              collection
            end

            # def filters
            #   [
            #     :generated_code_amount_lteq,
            #     :creator_cont
            #   ]
            # end

            def search_field_predicate
              :creator_name_or_metadata_school_cont
            end

            # def filters_with_values
            #   {
            #     generated_code_amount_lteq: :used_code_amount
            #   }
            # end
          end
        end
      end
    end
  end
end
